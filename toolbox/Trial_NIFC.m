classdef Trial_NIFC
    % Class defining a single N-interval forced-choice trial
    %   Detailed explanation goes here
    
    properties (SetAccess = immutable)
        nIntervals;
        targetModulation;
        referenceModulation;
        
        targetPresent;
        targetInterval;
        modulations;
        
        ISI;
    end
    
    properties (SetAccess = protected)
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
            parser.addParameter('targetInterval',[],@isnumeric);
            parser.addParameter('ISI',.5,@isnumeric);
            parser.parse(nIntervals, targetModulation, referenceModulation, varargin{:});
            
            %% Assign properties
            obj.nIntervals = parser.Results.nIntervals;
            obj.targetModulation = parser.Results.targetModulation;
            obj.referenceModulation = parser.Results.referenceModulation;
            obj.ISI = parser.Results.ISI;
            
            %% Assign target vs. reference interval
            obj.targetPresent = false(1,obj.nIntervals);
            if isempty(parser.Results.targetInterval)
                obj.targetInterval = randi(obj.nIntervals);
            else
                obj.targetInterval = parser.Results.targetInterval;
            end
            obj.targetPresent(obj.targetInterval) = true;
            
            %% Assign modulations to intervals
            obj.modulations = repmat(obj.referenceModulation,[obj.nIntervals, 1]);
            obj.modulations(obj.targetPresent) = repmat(obj.targetModulation,[sum(obj.targetPresent), 1]);
            
            %% Intialize
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
                mglWaitSecs(obj.ISI);
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
                obj.correct = all(obj.response{1} == obj.targetPresent);
            end
            
            %% Finalize
            obj.done = true;
        end
    end
end