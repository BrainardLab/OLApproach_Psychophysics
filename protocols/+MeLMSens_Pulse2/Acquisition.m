classdef Acquisition < handle
    %ACQUISITION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        describe;
    end
    properties % Directions
        background(1,1);
        pedestalDirection(1,1);
        pedestalPresent(1,1) logical;
        receptors;
    end
    properties % Durations
        adaptationDuration(1,1) duration = minutes(0);
        ISI(1,1) duration = seconds(.5);
        rampDuration(1,1) duration = seconds(.5);
        preRampDuration(1,1) duration = seconds(.25);
        postRampDuration(1,1) duration = seconds(0);
    end
    properties % Flicker params
        flickerBackgroundRGB = [.5 .5 .5]';
        flickerDuration(1,1) duration = seconds(.5);
        flickerFrequency(1,1) = 5; % Hz
        flickerFrameRate(1,1) = 60; %Hz
    end
    properties
        staircase(1,1) Staircases.InterleavedStaircase;
        trials = [];
    end
    properties (Dependent)
        NTrialsRemaining;
        NTrialsTotal;
    end
    
    properties % Modulations
        ISModulation(1,1) OLModulation;
        preModulation(1,1) OLModulation;
        postModulation(1,1) OLModulation;
        referenceModulation(1,1) projectorSpot.DisplayObjectModulation;
    end
    
    methods
        function makeModulations(obj)
            assert(~isempty(obj.background));
            assert(~isempty(obj.pedestalDirection));
            assert(~isempty(obj.pedestalPresent));
            
            OLFrameRate = 200;
            
            % IS modulation
            obj.ISModulation = MeLMSens_Pulse2.makeISModulation(...
                obj.background,...
                obj.pedestalDirection,...
                obj.pedestalPresent,...
                obj.ISI,...
                OLFrameRate);
            
            % Pre modulation
            obj.preModulation = MeLMSens_Pulse2.makePreModulation(...
                obj.background,...
                obj.pedestalDirection,...
                obj.pedestalPresent,...
                obj.rampDuration,...
                OLFrameRate);
            
            % Post modulation
            obj.postModulation = MeLMSens_Pulse2.makePostModulation(...
                obj.background,...
                obj.pedestalDirection,...
                obj.pedestalPresent,...
                obj.rampDuration,...
                OLFrameRate);
            
            % Reference modulation
            obj.referenceModulation = MeLMSens_Pulse2.makeReferenceModulation(...
                obj.flickerBackgroundRGB,...
                obj.flickerDuration,...
                obj.flickerFrameRate);
        end
        function stimulus = dummyStimulus(obj)
            stimulus = MeLMSens_Pulse2.Stimulus();
            stimulus.interstimulusModulation = obj.ISModulation;
            stimulus.preModulation = obj.preModulation;
            stimulus.postModulation = obj.postModulation;
            stimulus.referenceModulation = obj.referenceModulation;
            stimulus.targetModulation = obj.referenceModulation;
        end
        function stimulus = makeStimulus(obj,flickerDelta)
            stimulus = obj.dummyStimulus();
            stimulus.targetModulation = MeLMSens_Pulse2.makeTargetModulation(...
                obj.flickerBackgroundRGB,...
                flickerDelta*1/255*[1; 1; 1],...
                obj.flickerFrequency,...
                obj.flickerDuration,...
                obj.flickerFrameRate);
        end
        function trial = dummyTrial(obj)
            trial = MeLMSens_Pulse2.Trial();
            trial.stimulus = obj.dummyStimulus();
        end
        function trial = makeTrial(obj,flickerDelta)
            trial = obj.dummyTrial();
            trial.stimulus = obj.makeStimulus(flickerDelta);
        end
        function trial = makeNextTrial(obj)
            flickerDelta = obj.staircase.pop();
            trial = makeTrial(obj,flickerDelta);
        end
        function [correct, abort, trial] = runNextTrial(obj,oneLight,pSpot,responseSys)
            % Make trial
            trial = obj.makeNextTrial();
            
            % Show trial
            pSpot.annulus.RGB = obj.flickerBackgroundRGB;
            OLShowDirection(obj.background, oneLight);
            abort = trial.run(oneLight,pSpot,responseSys);
            OLShowDirection(obj.background, oneLight);
            
            % Process response
            if ~abort
                % Update staircases
                correct = trial.correct;
                obj.staircase.updateStaircase(trial.correct);

                % Save to list
                obj.trials = [obj.trials trial];
            end
        end
        function NTrialsRemaining = get.NTrialsRemaining(obj)
            NTrialsRemaining = sum(obj.staircase.nTrialsRemaining);
        end
        function NTrialsTotal = get.NTrialsTotal(obj)
            NTrialsTotal = obj.staircase.NTrialsPerStaircase * obj.staircase.NInterleavedStaircases;
        end
        function [threshold, PFParams] = fitPsychometricFunctionThreshold(obj)
            % Fit psychometric function
            psychometricFunction = @PAL_Weibull;
            paramsInitialGuess = Weibull_initialParamsGuess(obj.staircase.stimulusLevels,.5);
            freeParams = [1 1 0 1];
            guessRateLimits = [0 .5];
            PFParams = obj.staircase.fitPsychometricFunction(psychometricFunction,freeParams,paramsInitialGuess,guessRateLimits);
                           
            % PF-based threshold
            criterion = 0.7071;
            threshold = Staircases.PsychometricFunctions.thresholdFromPsychometricFunction(psychometricFunction,PFParams,criterion);
        end
        function plot(obj)
            [threshold, PFParams] = obj.fitPsychometricFunctionThreshold();
            F = obj.staircase.plot('threshold',threshold,'criterion',0.7071);
            ax = F.Children(1);
            color = ax.ColorOrder(ax.ColorOrderIndex-3,:);
            Staircases.PsychometricFunctions.plotPsychometricFunction(@PAL_Weibull,PFParams,unique(obj.staircase.stimulusLevels),'ax',ax,'Color',color);
        end
    end
end