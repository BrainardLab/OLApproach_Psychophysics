classdef InterleavedStaircase < handle
    %STAIRCASE Summary of this class goes here
    %   Detailed explanation goes here
    
    % Staircase related properties
    properties
        NInterleavedStaircases = 3;
        
        staircaseType = 'standard';
        
        stimulusStep(1,1);
        stimulusMin(1,1);
        stimulusMax(1,1);
        
        NTrialsPerStaircase;
        
        nUps = [2 2 2];
        nDowns = [1 1 1];
        
        stepSizes;
        
        rngSettings = rng('shuffle');
    end
    properties (Dependent)
        stimulusLevels;
        corrects;
        stimulusStepSizes;
        nextStimulusLevel;
    end
    properties (Access = protected)
        staircases;
        currentStaircase = 1;
        currentStimulusLevel;
        nTrialsRemaining;
    end
    properties (Dependent, Access = protected)
        availableStaircases;
    end
    
    methods
        function stimulusStepSizes = get.stimulusStepSizes(obj)
            stimulusStepSizes = obj.stimulusStep .* obj.stepSizes;
        end
        
        function initialize(obj)
            % Initialize staircases
            assert(isempty(obj.nTrialsRemaining),'Staircases have alread been initialized');
            
            % Create underlying staircases
            for k = 1:obj.NInterleavedStaircases
                stimulusLevels = (obj.stimulusMin:obj.stimulusStep:obj.stimulusMax);
                initialGuess = randsample(stimulusLevels,1);
                obj.staircases{k} = Staircase(obj.staircaseType,initialGuess, ...
                    'StepSizes', obj.stepSizes,...
                    'NUp', obj.nUps(k),...
                    'NDown', obj.nDowns(k), ...
                    'MaxValue', obj.stimulusMax,...
                    'MinValue', obj.stimulusMin);
                obj.nTrialsRemaining(k) = obj.NTrialsPerStaircase;
            end
        end
        
        function availableStaircases = get.availableStaircases(obj)
            availableStaircases = find(obj.nTrialsRemaining > 0);
        end
        
        function stimulusLevel = get.currentStimulusLevel(obj)
            stimulusLevel = getCurrentlevel(obj.staircases{obj.currentStaircase});
        end
        
        function stimulusLevel = get.nextStimulusLevel(obj)
            % Find available (non-completed) staircases
            assert(~isempty(obj.availableStaircases),'No trials remaining');
            
            % Pick one
            obj.currentStaircase = obj.availableStaircases(randi(numel(obj.availableStaircases)));
            
            % Get staircase level
            stimulusLevel = getCurrentstimulusLevel(obj);
        end
        
        function updateStaircase(obj, correct)
            obj.staircases{obj.currentStaircase} = updateForTrial(obj.staircases{obj.currentStaircase},...
                obj.getCurrentstimulusLevel,...
                correct);
            
            % Update nTrialsRemaining
            obj.nTrialsRemaining(obj.currentStaircase) = obj.nTrialsRemaining(obj.currentStaircase)-1;
        end
        
        function stimulusLevels = get.stimulusLevels(obj)
            % Extract stimulus level per trial separate for staircases
            for k = 1:numel(obj.staircases)
                values{k} = getTrials(obj.staircases{k});
                nTrials(k) = length(values{k});
            end
            nTrials = min(nTrials);
            for k = 1:numel(obj.staircases)
                stimulusLevels(:,k) = values{k}(1:nTrials);
            end
        end
        function corrects = get.corrects(obj)
            % Extract correct/incorrect per trial separate for staircases
            for k = 1:numel(obj.staircases)
                [correct{k}] = getTrials(obj.staircases{k});
                nTrials(k) = length(correct{k});
            end
            nTrials = min(nTrials);
            for k = 1:numel(obj.staircases)
                corrects(:,k) = correct{k}(1:nTrials);
            end
            corrects = logical(corrects);
        end
    end
end