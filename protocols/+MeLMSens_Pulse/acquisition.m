classdef acquisition < handle
    % Class defining an acquisition of LMSensitivity on steady adaptation
    %
    %   Detailed explanation goes here
    
    % Descriptors
    properties
        name;
        describe;
    end
    
    % Directions
    properties
        background;
        pedestalDirection;
        pedestalPresent;
        flickerDirection;
        receptors;
        
        % Post-validation
        validationAtThreshold;
    end
    properties (Dependent)
        flickerBackground;
        maxContrast;
    end
    
    % Timing related properties
    properties
        ISI = .5;
        adaptationDuration = minutes(5);
        
        flickerWaveform;
        
        % flicker parameters
        samplingFq = 200;
        flickerFrequency = 5;
        flickerDuration = seconds(.5);
    end
    
    % Staircase related properties
    properties
        staircases;
        threshold;
        
        % Staircase parameters
        staircaseType = 'standard';
        contrastStep = 0.001;
        minContrast = 0;
        contrastLevels;
        NTrialsPerStaircase = 40;
        NInterleavedStaircases = 3;
        stepSizes;
        nUps = [2 2 2];
        nDowns = [1 1 1];
        rngSettings;
    end
    properties %(Access = protected)
        currentStaircase = 1;
        nTrialsRemaining;
    end
    
    properties
        trials = [];
    end
    
    methods
        function obj = acquisition(background, pedestalDirection, pedestalPresent, flickerDirection, receptors, varargin)
            % Constructor
            
            % Input validation
            parser = inputParser;
            parser.addRequired('background',@(x) isa(x,'OLDirection_unipolar'));
            parser.addRequired('pedestalDirection',@(x) isa(x,'OLDirection_unipolar'));
            parser.addRequired('pedestalPresent',@islogical);
            parser.addRequired('flickerDirection',@(x) isa(x,'OLDirection_bipolar'));
            parser.addRequired('receptors',@(x) isa(x,'SSTReceptor') || isnumeric(x));
            parser.addParameter('name',"",@(x) ischar(x) || isstring(x));
            parser.addParameter('describe',struct(),@isstruct);
            parser.parse(background, pedestalDirection, pedestalPresent, flickerDirection,receptors,varargin{:});
            
            % Assign properties
            % Name, describe
            obj.name = parser.Results.name;
            obj.describe = parser.Results.describe;
            obj.describe.name = obj.name;
            
            % Direction-related
            obj.background = background;
            obj.pedestalDirection = pedestalDirection;
            obj.pedestalPresent = pedestalPresent;
            obj.flickerDirection = flickerDirection;
            obj.receptors = receptors;
        end
        
        function flickerBackground = get.flickerBackground(obj)
            if obj.pedestalPresent
                flickerBackground = obj.background + obj.pedestalDirection;
            else
                flickerBackground = obj.background;
            end
        end
        
        function maxContrast = get.maxContrast(obj)
            % Figure out max contrast: smallest of the nominal max L, M, S
            % contrasts
            nominalContrasts = obj.flickerDirection.ToDesiredReceptorContrast(obj.flickerBackground, obj.receptors);
            nominalContrasts = abs(nominalContrasts(1:3,:));
            maxContrast = min(nominalContrasts(:));
        end
        
        function initializeStaircases(obj)
            % Initialize staircases
            
            assert(isempty(obj.nTrialsRemaining),'Staircases have alread been initialized');
            
            % Setup contrast levels
            obj.contrastLevels = (0:obj.contrastStep:obj.maxContrast);
            obj.stepSizes = [8*obj.contrastStep 4*obj.contrastStep 2*obj.contrastStep obj.contrastStep];
            
            obj.rngSettings = rng('shuffle');
            for k = 1:obj.NInterleavedStaircases
                initialGuess = randsample(obj.contrastLevels,1);
                obj.staircases{k} = Staircase(obj.staircaseType,initialGuess, ...
                    'StepSizes', obj.stepSizes, 'NUp', obj.nUps(k), 'NDown', obj.nDowns(k), ...
                    'MaxValue', obj.maxContrast, 'MinValue', obj.minContrast);
                obj.nTrialsRemaining(k) = obj.NTrialsPerStaircase;
            end
        end
        
        function showAdaptation(obj, oneLight)
            % Show adaptation spectrum for adaptation period (preceding any trials)
            OLAdaptToDirection(obj.background, oneLight, obj.adaptationDuration);
        end
        
        function runAcquisition(obj, oneLight, responseSys)
            % Run the acquisition
            % Create flickerWaveform;
            obj.flickerWaveform = sinewave(obj.flickerDuration,obj.samplingFq,obj.flickerFrequency);
            
            % Adapt
            Speak('Press key to start adaptation',[],230);
            responseSys.waitForResponse;
            obj.showAdaptation(oneLight);
            responseSys.waitForResponse;
            
            % Run trials
            abort = false;
            for ntrial = 1:obj.NTrialsPerStaircase % loop over trial numbers
                for k = Shuffle(1:obj.NInterleavedStaircases) % loop over staircases, in randomized order
                    if ~abort                   
                        % Run trial
                        [~, abort, ~] = obj.runTrial(flickerContrast, oneLight, responseSys);                       
                    end
                end
            end
            if abort
                throw(MException('OLApproach_PsychophysicsEngine:UserAbort', ...
                    'User aborted acquisition.'));
            end
        end
        
        function staircaseValue = getNextStaircaseValue(obj)
            % Find available (non-completed) staircases
            availableStaircases = find(obj.nTrialsRemaining > 0);
            assert(~isempty(availableStaircases),'No trials remaining');
            
            % Pick one
            obj.currentStaircase = availableStaircases(randi(numel(availableStaircases)));
                        
            % Get staircase value
            staircaseValue = getCurrentStaircaseValue(obj); 
        end
        
        function bool = hasNextTrial(obj)
            bool = any(obj.nTrialsRemaining > 0);            
        end
        
        function staircaseValue = getCurrentStaircaseValue(obj)
            staircaseValue = getCurrentValue(obj.staircases{obj.currentStaircase});
        end
        
        function updateStaircase(obj, correct)
            obj.staircases{obj.currentStaircase} = updateForTrial(obj.staircases{obj.currentStaircase},...
                obj.getCurrentStaircaseValue,...
                correct);
            
            % Update nTrialsRemaining
            obj.nTrialsRemaining(obj.currentStaircase) = obj.nTrialsRemaining(obj.currentStaircase)-1;            
        end
        
        function [correct, abort, trial] = runNextTrial(obj, oneLight, trialResponseSys)
            % Run next trial in acquisition
            
            % Get contrast value
            flickerContrast = obj.getNextStaircaseValue();
            
            % Assemble modulations
            trial = MeLMSens_Pulse.assembleTrial(obj.background,obj.pedestalDirection,obj.flickerDirection,obj.pedestalPresent,flickerContrast,obj.receptors);
            
            % Show trial
            OLShowDirection(obj.background, oneLight);
            [abort, trial] = trial.run(oneLight,obj.samplingFq,trialResponseSys);
            OLShowDirection(obj.background, oneLight);
            if ~abort
                % Update staircases
                correct = trial.correct;
                obj.updateStaircase(trial.correct);

                % Save to list
                obj.trials = [obj.trials trial];
            end
        end
        
        function postAcquisition(obj, oneLight, radiometer)
            % Get threshold estimate
            obj.threshold = obj.fitPsychometricFunctionThreshold();
            
            % Validate contrast at threshold
            desiredContrast = [1 1 1 0; -1 -1 -1 0]' * obj.threshold;
            scaledDirection = obj.flickerDirection.ScaleToReceptorContrast(obj.flickerBackground, obj.receptors, desiredContrast);
            for v = 1:5
                obj.validationAtThreshold = OLValidateDirection(scaledDirection,obj.flickerBackground, oneLight, radiometer, 'receptors', obj.receptors);
            end
        end
    end
    
    methods % Psychometric function fitting
        function PFParams = fitPsychometricFunction(obj, psychometricFunction)
            % Fit with Palemedes Toolbox. Really want to plot the fit
            % against the data to make sure it is reasonable in practice.
            
            % Define what psychometric functional form to fit.
            % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal,
            % PAL_HyperbolicSecant
            
            % Extract values, correct/incorrect
            contrastValue = zeros(obj.NTrialsPerStaircase,obj.NInterleavedStaircases);
            correct = false(obj.NTrialsPerStaircase,obj.NInterleavedStaircases);
            for k = 1:numel(obj.staircases)
                [contrastValues, corrects] = getTrials(obj.staircases{k});
                contrastValue(1:length(contrastValues),k) = contrastValues(1:length(contrastValues));
                correct(1:length(corrects),k) = corrects(1:length(corrects));
            end
            correct = logical(correct);
            contrastValue = round(contrastValue,6);
            
            % Put data in format for PAL:
            % `stimLevels` vector of contrastValues/levels used
            % `nCorrect` number of correct responses for each stim level
            % `n` number of total trials for each stim level
            % `PF` handle to psychometric function
            % `paramsFree` vector of which PF parameters to vary
            % `initialParamsGuess` initial guess of parameter values
            stimLevels = unique(contrastValue(:));
            for i = 1:length(stimLevels)
                n(i) = sum(contrastValue(:) == stimLevels(i));
                nCorrect(i) = sum(correct(contrastValue == stimLevels(i)));
            end
            
            % Define initial parameter guesses.
            initialParamsGuess = [];
            
            % The first two parameters of the Weibull define its shape.
            % Setting the first parameter to the middle of the stimulus
            % range and the second to 1 puts things into a reasonable
            % ballpark here.
            initialParamsGuess(1) = mean([obj.maxContrast,obj.minContrast]);
            initialParamsGuess(2) = 1;
            
            % The third is the guess rate, which determines the value the
            % function takes on at x = 0.  For 2IFC, this should be locked
            % at 0.5.
            guessRate = .5;
            initialParamsGuess(3) = guessRate;
            
            % The fourth parameter is the lapse rate - the asymptotic
            % performance at high values of x.  For a perfect subject, this
            % would be 0, but sometimes subjects have a "lapse" and get the
            % answer wrong even when the stimulus is easy to see.  We can
            % search over this, but shouldn't allow it to take on
            % unreasonable values.  0.05 as an upper limit isn't crazy.
            lapseLimits = [0 0.05];
            initialParamsGuess(4) = mean(lapseLimits);
            
            % paramsFree is a boolean vector that determines what
            % parameters get searched over. 1: free parameter, 0: fixed
            % parameter
            paramsFree = [1 1 0 1];
            
            % Set up standard options for Palamedes search
            options = PAL_minimize('options');
            
            % Do the search to get the parameters
            PFParams = PAL_PFML_Fit(...
                stimLevels,nCorrect',n', ...
                initialParamsGuess,paramsFree,...
                psychometricFunction,...
                'searchOptions',options,...
                'lapseLimits',lapseLimits);
        end
        
        function threshold = fitPsychometricFunctionThreshold(obj)
            % Fit psychometric function
            psychometricFunction = @PAL_Weibull;
            PFParams = obj.fitPsychometricFunction(psychometricFunction);
            
            % PF-based threshold
            criterion = 0.7071;
            threshold = thresholdFromPsychometricFunction(psychometricFunction,PFParams,criterion);
        end
    end
    
    methods % Plotting
        function F = plot(obj, varargin)
            % Plot all trials of this acquisition
            
            % Parse input
            parser = inputParser();
            parser.addRequired('obj');
            parser.addParameter('F',figure(),@(x) isgraphics(x) && strcmp(x.Type,'figure'));
            parser.parse(obj,varargin{:});
            F = parser.Results.F;
            figure(F);
            
            % Plot staircases
            ax_staircases = subplot(1,2,1);
            obj.plotStaircases('ax',ax_staircases);
            
            % Plot psychometric function
            ax_psychometricFunction = subplot(1,2,2);
            obj.plotPsychometricFunction('ax',ax_psychometricFunction);
        end
        
        function ax = plotStaircases(obj,varargin)
            % Plot all trials of this acquisition
            
            % Parse input
            parser = inputParser();
            parser.addRequired('obj');
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;
            axes(ax); hold on;
            
            % Plot staircases trialseries
            plotStaircaseTrialseries([obj.staircases{1:3}],'ax',ax,'threshold',[]);
            
            % Plot mean threshold
            color = ax.ColorOrder(ax.ColorOrderIndex,:); % current plot color, which we'll reuse)
            plot(xlim,obj.threshold*[1 1],'--','Color',color);
            text(10,obj.threshold+0.001,...
                sprintf('Fit threshold = %.3f',mean(obj.threshold)),...
                'Color',color,...
                'FontWeight','bold');
            
            % Finish up
            ylabel('LMS contrast (ratio)');
            ylim([0,0.05]);
            title('Staircase trials');
            hold off;
        end
        
        function PFGroup = plotPsychometricFunction(obj,varargin)
            % Plot psychometric function fit to this acquisition
            
            % Parse input
            parser = inputParser();
            parser.addRequired('obj');
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;
            
            % Plot proportionCorrect
            color = ax.ColorOrder(ax.ColorOrderIndex,:);
            staircase = [obj.staircases{1} obj.staircases{2} obj.staircases{3}];
            dataPoints = plotStaircaseProportionCorrect(staircase,...
                'ax',ax,...
                'binSize',10);
            dataPoints.DisplayName = sprintf('%s %s',obj.name,dataPoints.DisplayName);
            
            % Fit psychometric function
            psychometricFunction = @PAL_Weibull;
            PFParams = obj.fitPsychometricFunction(psychometricFunction);
            
            % Create group
            PFGroup = hggroup();
            PFGroup.DisplayName = sprintf('%s psychometric function fit',obj.name);
            
            % Plot a smooth curve with the parameters for all contrast
            % levels
            PFLine = plotPsychometricFunction(psychometricFunction,PFParams,obj.contrastLevels,...
                'ax',ax,...
                'color',color);
            PFLine.Parent = PFGroup;
            
            % PF-based threshold
            criterion = 0.7071;
            ax.ColorOrderIndex = ax.ColorOrderIndex -1; % plot threshold in same color as fitline
            thresholdGroup = plotPFThreshold(psychometricFunction,PFParams,criterion,...
                'ax',ax,...
                'color',color);
            thresholdGroup.Parent = PFGroup;
            
            % Annotate
            title('Weibull function, fitted');
            xlabel('LMS contrast (ratio)');
            ylabel('Proportion correct');
            hold off;
        end
    end
end