classdef Acquisition_FlickerSensitivity_2IFC < handle
    % Class defining an acquisition of LMSensitivity on steady adaptation
    %
    %   Detailed explanation goes here
    
    %% Descriptors
    properties
        name;
        describe;
    end
    
    %% Directions
    properties
        background;
        direction;
        receptors;
        
        % Post-validation
        validationAtThreshold;
    end
    properties (Dependent)
        maxContrast;
    end
    
    %% Timing related properties
    properties
        ISI = .5;
        adaptationDuration = minutes(5);
        
        flickerWaveform;
        
        % flicker parameters
        samplingFq = 200;
        flickerFrequency = 5;
        flickerDuration = .5;
    end
    
    %% Staircase related properties
    properties
        staircases;
        thresholds;
        
        % Staircase parameters
        staircaseType = 'standard';
        contrastStep = 0.001;
        minContrast = 0;
        contrastLevels;
        NTrialsPerStaircase = 40;
        NInterleavedStaircases = 3;
        stepSizes;
        nUps = [3 2 1];
        nDowns = [1 1 1];
        rngSettings;
    end
    properties
        trials = [];
    end
    
    %% Methods
    methods
        function obj = Acquisition_FlickerSensitivity_2IFC(background, direction, receptors, varargin)
            %% Constructor
            
            %% Input validation
            parser = inputParser;
            parser.addRequired('background',@(x) isa(x,'OLDirection_unipolar'));
            parser.addRequired('direction',@(x) isa(x,'OLDirection_bipolar'));
            parser.addRequired('receptors',@(x) isa(x,'SSTReceptor') || isnumeric(x));
            parser.addParameter('name',"",@(x) ischar(x) || isstring(x));
            parser.addParameter('describe',struct(),@isstruct);
            
            parser.parse(background,direction,receptors,varargin{:});
            
            %% Assign properties
            % Name, describe
            obj.name = parser.Results.name;
            obj.describe = parser.Results.describe;
            obj.describe.name = obj.name;
            
            % Direction-related
            obj.background = background;
            obj.direction = direction;
            obj.receptors = receptors;
        end
        
        function maxContrast = get.maxContrast(obj)
            % Figure out max contrast: smallest of the nominal max L, M, S
            % contrasts
            nominalContrasts = obj.direction.ToDesiredReceptorContrast(obj.background, obj.receptors);
            nominalContrasts = abs(nominalContrasts(1:3,:));
            maxContrast = min(nominalContrasts(:));
        end
        
        function initializeStaircases(obj)
            %% Initialize staircases
            
            %% Setup contrast levels
            obj.contrastLevels = (0:obj.contrastStep:obj.maxContrast);
            obj.stepSizes = [4*obj.contrastStep 2*obj.contrastStep obj.contrastStep];
            
            obj.rngSettings = rng('shuffle');
            for k = 1:obj.NInterleavedStaircases
                initialGuess = randsample(obj.contrastLevels,1);
                obj.staircases{k} = Staircase(obj.staircaseType,initialGuess, ...
                    'StepSizes', obj.stepSizes, 'NUp', obj.nUps(k), 'NDown', obj.nDowns(k), ...
                    'MaxValue', obj.maxContrast, 'MinValue', obj.minContrast);
            end
        end
        
        function showAdaptation(obj, oneLight)
            %% Show adaptation spectrum for adaptation period (preceding any trials)
            OLAdaptToDirection(obj.background, oneLight, obj.adaptationDuration);
        end
        
        function runAcquisition(obj, oneLight, responseSys)
            %% Run the acquisition
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
                        % Get contrast value
                        flickerContrast = getCurrentValue(obj.staircases{k});
                        
                        % Run trial
                        [correct, abort, trial] = obj.runTrial(flickerContrast, oneLight, responseSys);
                        obj.trials = [obj.trials trial];
                        
                        % Update modulation parameters, according to staircase
                        obj.staircases{k} = updateForTrial(obj.staircases{k}, flickerContrast, correct);
                    end
                end
            end
            if abort
                throw(MException('OLApproach_PsychophysicsEngine:UserAbort', ...
                    'User aborted acquisition.'));
            end
        end
        
        function [correct, abort, trial] = runTrial(obj, flickerContrast, oneLight, trialResponseSys)
            %% Assemble trial
            % Assemble modulations
            scaledDirection = obj.direction.ScaleToReceptorContrast(obj.background, obj.receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
            targetModulation = OLAssembleModulation([obj.background, scaledDirection],[ones(1,length(obj.flickerWaveform)); obj.flickerWaveform]);
            referenceModulation = OLAssembleModulation(obj.background, ones([1,length(obj.flickerWaveform)]));
            trial = Trial_NIFC(2,targetModulation,referenceModulation);
            
            %% Show trial
            OLShowDirection(obj.background, oneLight);
            [abort, trial] = trial.run(oneLight,obj.samplingFq,trialResponseSys);
            OLShowDirection(obj.background, oneLight);
            
            correct = trial.correct;
        end
        
        function postAcquisition(obj, oneLight, radiometer)
            % Get threshold estimate
            for k = 1:obj.NInterleavedStaircases
                obj.thresholds(k) = getThresholdEstimate(obj.staircases{k});
            end
            
            % Validate contrast at threshold
            desiredContrast = [1 1 1 0; -1 -1 -1 0]' * mean(obj.thresholds);
            scaledDirection = obj.direction.ScaleToReceptorContrast(obj.background, obj.receptors, desiredContrast);
            for v = 1:5
                obj.validationAtThreshold = OLValidateDirection(scaledDirection,obj.background, oneLight, radiometer, 'receptors', obj.receptors);
            end
        end
        
        function F = plot(obj, varargin)
            % Plot all trials of this acquisition
            
            % Parse input
            parser = inputParser();
            parser.addRequired('obj',@(x)isa(x,'Acquisition_FlickerSensitivity_2IFC'));
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
            parser.addRequired('obj',@(x)isa(x,'Acquisition_FlickerSensitivity_2IFC'));
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;
            
            % Plot staircases
            axes(ax); hold on;
            plotStaircase([obj.staircases{1:3}],'ax',ax);
            ylabel('LMS contrast (ratio)');
            ylim([0,0.05]);
            title('Staircase trials');
            plot(xlim,mean(obj.thresholds)*[1 1],'--');
            text(10,mean(obj.thresholds)+0.001,...
                sprintf('Mean threshold = %.3f',mean(obj.thresholds)),...
                'Color',ax.ColorOrder(ax.ColorOrderIndex-1,:),...
                'FontWeight','bold');
            hold off;
        end
        
        function ax = plotPsychometricFunction(obj,varargin)
             % Plot psychometric function fit to this acquisition
            
            % Parse input
            parser = inputParser();
            parser.addRequired('obj',@(x)isa(x,'Acquisition_FlickerSensitivity_2IFC'));
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;            
            
            % Fit psychometric function
            psychometricFunction = @PAL_Weibull;
            PFParams = obj.fitPsychometricFunction(psychometricFunction);
            
            % Make a smooth curve with the parameters for all contrast
            % levels
            axes(ax); hold on;
            probabilityCorrectPF = psychometricFunction(PFParams,obj.contrastLevels);
            p = plot(obj.contrastLevels,probabilityCorrectPF);
            p.Tag = [char(obj.name) ' Psychometric Function'];
            title('Weibull function, fitted');
            ylabel('Percent correct');
            xlabel('LMS contrast (ratio)');
            
            % PF-based threshold
            criterion = 0.7071;
            threshold = obj.psychometricFunctionThreshold(psychometricFunction,PFParams,criterion);
            ax.ColorOrderIndex = ax.ColorOrderIndex-1;
            plot([0 threshold],criterion*[1 1],'--');
            ax.ColorOrderIndex = ax.ColorOrderIndex-1;            
            plot(threshold*[1 1],[0.5 criterion],'--');
            text(threshold,0,sprintf('%s Threshold = %.3f (%.2f %%correct)',obj.name,threshold,criterion*100));
            hold off;            
        end
        
        function PFParams = fitPsychometricFunction(obj, psychometricFunction)
            % Fit with Palemedes Toolbox. Really want to plot the fit
            % against the data to make sure it is reasonable in practice.
            
            % Define what psychometric functional form to fit.
            % Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal,
            % PAL_HyperbolicSecant
            
            % Extract values, correct/incorrect
            for k = 1:numel(obj.staircases)
                [contrastValue(:,k), correct(:,k)] = getTrials(obj.staircases{k});
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
end