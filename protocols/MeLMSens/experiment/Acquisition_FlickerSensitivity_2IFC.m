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
        validatedContrastAtThresholdPos;
        validatedContrastAtThresholdNeg;
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
    end
end