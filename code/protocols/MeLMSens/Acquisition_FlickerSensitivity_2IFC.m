classdef Acquisition_FlickerSensitivity_2IFC < handle
    % Class defining an acquisition of LMSensitivity on steady adaptation
    %
    %   Detailed explanation goes here
    
    %% Directions
    properties
        background;
        direction;
        receptors;
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
        
        % Staircase parameters
        staircaseType = 'standard';
        contrastStep = 0.005;
        maxContrast = 0.05;
        minContrast;
        contrastLevels;
        NTrialsPerStaircase = 40;
        NInterleavedStaircases = 3;
        stepSizes;
        nUps = [3 2 1];
        nDowns = [1 1 1];
        rngSettings;
    end
    
    %% Keybindings
    properties
        keyBindings = containers.Map();
    end
    
    %% Methods
    methods
        function obj = Acquisition_FlickerSensitivity_2IFC(direction, background, receptors)
            %% Constructor
            obj.background = background;
            obj.direction = direction;
            obj.receptors = receptors;
            
            % Set keybindings
            obj.keyBindings('Q') = 'abort';
            obj.keyBindings('ESCAPE') = 'abort';
            obj.keyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
            obj.keyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
        end
        
        function initializeStaircases(obj)
            %% Initialize staircases
            obj.minContrast = obj.contrastStep;
            obj.contrastLevels = (0:obj.contrastStep:obj.maxContrast);
            obj.stepSizes = [4*obj.contrastStep 2*obj.contrastStep obj.contrastStep];
            
            obj.rngSettings = rng('default');
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
            
        function runAcquisition(obj, oneLight)
            %% Run the acquisition
            % Create flickerWaveform;
            obj.flickerWaveform = sinewave(obj.flickerDuration,obj.samplingFq,obj.flickerFrequency);
            
            % Adapt
            %obj.showAdaptation(oneLight);
            
            % Run trials
            abort = false;
            for ntrial = 1:obj.NTrialsPerStaircase % loop over trial numbers
                for k = Shuffle(1:obj.NInterleavedStaircases) % loop over staircases, in randomized order            
                    if ~abort
                        % Get contrast value                    
                        flickerContrast = getCurrentValue(obj.staircases{k});

                        % Assemble modulations
                        scaledDirection = obj.direction.ScaleToReceptorContrast(obj.background, obj.receptors, [flickerContrast, flickerContrast, flickerContrast, 0]');
                        
                        targetModulation = OLAssembleModulation([obj.background, scaledDirection],...
                            [ones(1,length(obj.flickerWaveform)); obj.flickerWaveform]);
                        
                        referenceModulation = OLAssembleModulation(obj.background,...
                            ones([1,length(obj.flickerWaveform)]));

                        % Determine which interval (1 or 2) will have flicker
                        targetPresent = logical([0 0]);
                        targetInterval = randi(length(targetPresent));
                        targetPresent(targetInterval) = true;

                        % Assemble trial
                        modulations = repmat(referenceModulation,[length(targetPresent),1]);
                        modulations(targetPresent) = targetModulation;

                        % Show modulations
                        for m = 1:length(modulations)
                            mglWaitSecs(obj.ISI);
                            Beeper;
                            OLFlicker(oneLight, modulations(m).starts, modulations(m).stops, 1/obj.samplingFq,1);
                            OLShowDirection(obj.background, oneLight);
                        end

                        % Response
                        % Get response from GamePad, but also listen to keyboard
                        while true
                            responseKey = upper(WaitForKeyChar);
                            if any(strcmp(responseKey,obj.keyBindings.keys()))
                                break;
                            end
                        end
                        response = obj.keyBindings(responseKey);

                        if ischar(response) && strcmp(response,'abort')
                            % User wants to abort
                            abort = true;
                            correct = false;
                        else
                            abort = false;

                            % Correct? Compare response
                            correct = all(response == targetPresent);
                        end

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
    end
end