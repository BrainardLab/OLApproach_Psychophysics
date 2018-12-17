classdef Trial_NIFC < handle
    % Class defining a single N-interval forced-choice trial
    %   Detailed explanation goes here
    
    properties
        nIntervals;
        targetModulation;
        referenceModulation;
        interstimulusModulation;        
        preModulation;
        postModulation;
        
        targetInterval;
    end
    
    properties (SetAccess = protected)
        intervals;
        modulations = struct([]);         
        response;
        correct = false;
        done = false;
    end
    
    methods
        function obj = Trial_NIFC(nIntervals, targetModulation, referenceModulation, varargin)
            % Construct an instance of the class, i.e., a single trial
            %
            % Syntax:
            %   trial = Trial_NIFC(nInterval, targetModulation, referenceModulation)
            %   trial = Trial_NIFC(nInterval, targetModulation, referenceModulation, targetInterval)
            %
            % Description:
            %    Description goes here.
            %
            % Inputs:
            %
            % Outputs:
            % 
            % Optional keyword arguments:
            %
            % See also:
            % 
            
            % History:
            %    07/18/18  jv  wrote it.
            
            %% Parse input
            parser = inputParser();
            parser.addRequired('nIntervals',@isnumeric);
            parser.addRequired('targetModulation');
            parser.addRequired('referenceModulation');
            parser.addParameter('preModulation',[]);
            parser.addParameter('postModulation',[]);
            parser.addParameter('interstimulusModulation',[]);
            parser.addParameter('targetInterval',[],@isnumeric);
            parser.addParameter('ISI',.5,@isnumeric);
            parser.parse(nIntervals, targetModulation, referenceModulation, varargin{:});
            
            %% Assign properties
            obj.nIntervals = parser.Results.nIntervals;
            obj.targetModulation = parser.Results.targetModulation;
            obj.referenceModulation = parser.Results.referenceModulation;
        end
        
        function obj = initializeIntervals(obj)
            %% Initialize intervals
            % initialize Nx1 struct-array with fields 
            % targetPresent: boolean indicating whether this interval
            %                contains a target,
            % modulation   : the modulation for that interval
            %
            % initialize all as target-absent intervals, containing the
            % reference modulation
            obj.intervals = struct('targetPresent',repmat({false},[obj.nIntervals,1]),...
                                   'modulation',repmat({obj.referenceModulation},[obj.nIntervals,1]));
        end
        
        function obj = assignTargetInterval(obj)           
            %% Assign target interval
            if isempty(obj.targetInterval)
                obj.targetInterval = randi(obj.nIntervals);
            end
            obj.intervals(obj.targetInterval).targetPresent = true;
            obj.intervals(obj.targetInterval).modulation = obj.targetModulation;
        end
        
        function obj = assembleModulations(obj)
            %% Collapes modulations, add pre, post, interstimulusModulation
            % pre, I(1), IS, I(2), IS,...,I(N), post
            obj.modulations = obj.preModulation;
            obj.modulations = [obj.modulations obj.intervals(1).modulation];
            for i = 2:length(obj.intervals)
                obj.modulations = [obj.modulations obj.interstimulusModulation];
                obj.modulations = [obj.modulations obj.intervals(i).modulation];
            end
            obj.modulations = [obj.modulations obj.postModulation];
        end
        
        function obj = initialize(obj)
            %% Intialize
            obj.initializeIntervals();
            obj.assignTargetInterval();
            obj.assembleModulations();
            obj.response = false(1,obj.nIntervals); 
        end
        
        function [abort, obj] = run(obj, oneLight, samplingFq, responseSys)
            % Summary of this method goes here
            %   Detailed explanation goes here
            if obj.done
                error('Trial already completed');
            end
            
            %% Show modulations      
            for m = 1:length(obj.modulations)
                Beeper;
                OLFlicker(oneLight, obj.modulations(m).starts, obj.modulations(m).stops, 1/samplingFq, 1);
            end
            
            %% Response
            obj.response = responseSys.waitForResponse();
            
            %% Process response
            if any(strcmpi(obj.response,'abort'))
                % User wants to abort
                abort = true;
            else
                abort = false;
                % Correct? Compare only first response
                obj.correct = all(obj.response{1} == [obj.intervals.targetPresent]);
            end
            
            %% Finalize
            obj.done = true;
        end
    end
end