classdef Acquisition < handle
    %ACQUISITION Summary of this class goes here
    %   Detailed explanation goes here
    
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
    end
end