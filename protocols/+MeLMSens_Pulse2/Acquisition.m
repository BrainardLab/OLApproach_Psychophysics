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
            PFParams = obj.fitPsychometricFunction(psychometricFunction,freeParams,paramsInitialGuess,guessRateLimits);
                           
            % PF-based threshold
            criterion = 0.7071;
            threshold = Staircases.PsychometricFunctions.thresholdFromPsychometricFunction(psychometricFunction,PFParams,criterion);
        end
        function PFParams = fitPsychometricFunction(obj)
            % Fit psychometric function
            psychometricFunction = @PAL_Weibull;
            paramsInitialGuess = Weibull_initialParamsGuess(obj.staircase.stimulusLevels,.5);
            freeParams = [1 1 0 1];
            guessRateLimits = [0 .5];
            PFParams = obj.staircase.fitPsychometricFunction(psychometricFunction,freeParams,paramsInitialGuess,guessRateLimits);
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
            plotStaircaseTrialseries([obj.staircases{1:3}],'ax',ax);
            
            % Plot mean threshold
            color = ax.ColorOrder(ax.ColorOrderIndex,:); % current plot color, which we'll reuse)
            plot(xlim,mean(obj.thresholds)*[1 1],'--','Color',color);
            text(10,mean(obj.thresholds)+0.001,...
                sprintf('Mean threshold = %.3f',mean(obj.thresholds)),...
                'Color',color,...
                'FontWeight','bold');
            
            % Finish up
            ylabel('LMS contrast (ratio)');
            ylim([0,0.05]);
            title('Staircase trials');
            hold off;
        end
        
        function PCGroup = plotProportionsCorrect(obj, varargin)
            % Plot trial proportions correct of this acquisition
 
            % Parse input
            parser = inputParser();
            parser.addRequired('obj');
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.KeepUnmatched = true;
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;
            parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
            parser.parse(obj,varargin{:});
            axes(ax); hold on;
            
            % Plot proportionCorrect
            dataPoints = obj.staircase.plotProportionCorrect(...
                'ax',ax,...
                'color',parser.Results.color);
            dataPoints.DisplayName = sprintf('%s %s',obj.name,dataPoints.DisplayName);

            % Annotate
            title('Detection performance');
            xlabel('LMS contrast (ratio)');
            ylabel('Percent correct');
            hold off;
        end
        
        function PFGroup = plotPsychometricFunction(obj,varargin)
             % Plot psychometric function fit to this acquisition
            
            % Parse input
            parser = inputParser();
            parser.addRequired('obj');
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.KeepUnmatched = true;
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;
            parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
            parser.parse(obj,varargin{:});
            axes(ax); hold on;
            
            % Fit psychometric function
            PFParams = obj.fitPsychometricFunction();
            
            % Plot a smooth curve with the parameters for all contrast
            % levels
            psychometricFunction = @PAL_Weibull;
            contrastLevels = obj.staircase.stimulusMin:1:obj.staircase.stimulusMax;
            PFLine = Staircases.PsychometricFunctions.plotPsychometricFunction(psychometricFunction,PFParams,contrastLevels,...
                'ax',ax,...
                'color',parser.Results.color,...
                varargin{:});
            PFLine.DisplayName = sprintf('%s psychometric function fit',obj.name);
            
           
            % Annotate
            title('Weibull function, fitted');
            xlabel('LMS contrast (ratio)');
            ylabel('Percent correct');
            hold off;
        end
        
        function threshold = plotPFThreshold(obj, varargin)
            % Parse input
            parser = inputParser();
            parser.addRequired('obj');
            parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
            parser.KeepUnmatched = true;
            parser.parse(obj,varargin{:});
            ax = parser.Results.ax;
            parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
            parser.parse(obj,varargin{:});
            axes(ax); hold on;
            
            % Fit psychometric function
            psychometricFunction = @PAL_Weibull;
            PFParams = obj.fitPsychometricFunction();
            
            % PF-based threshold
            criterion = 0.7071;
            threshold = Staircases.PsychometricFunctions.plotPFThreshold(psychometricFunction,PFParams,criterion,...
                'ax',ax,...
                'color',parser.Results.color);
            threshold.DisplayName = sprintf('%s %s',obj.name,threshold.Children(1).DisplayName);
            
            % Annotate
            title('Threshold from pyschometric function');
            xlabel('LMS contrast (ratio)');
            ylabel('Percent correct');
            hold off;
        end
    end
end