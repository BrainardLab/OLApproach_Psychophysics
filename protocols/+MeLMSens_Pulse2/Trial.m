classdef Trial < handle
    %TRIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stimulus(1,1) MeLMSens_Pulse2.Stimulus;
    end
    properties (SetAccess = protected)
        response;
        correct = false;
        done = false;
    end
    
    methods %Constructor, Setters
        function obj = Trial(varargin)
            parser = inputParser;
            parser.addParameter('stimulus',MeLMSens_Pulse2.Stimulus,...
                @(x) validatattributes(x,{'MeLMSens_Pulse2.Stimulus'},{'scalar'}));
            parser.parse(varargin{:});
            
            obj.stimulus = parser.Results.stimulus;
        end
        
        function set.stimulus(obj,stimulus)
            assert(~obj.done,'Cannot change properties of completed trial');
            obj.stimulus = stimulus;
        end
    end
    
    methods
        function abort = run(obj, oneLight, pSpot, responseSys)
            % Run given trial
            %
            % Syntax:
            %   run(trial, oneLight, projectorSpot, responseSystem)
            %   trial.run(oneLight, projectorSpot, responseSystem)
            %
            % Description:
            %    Detailed explanation goes here
            
            % Assert preconditions
            assert(~obj.done,'Trial already completed');
            assert(~isempty(obj.stimulus),'No stimulus specified');
            
            % Parse input
            parser = inputParser;
            parser.addRequired('obj');
            parser.addRequired('oneLight',@(x) isa(x,'OneLight'));
            parser.addRequired('pSpot',@(x) isa(x,'projectorSpot.projectorSpot'));
            parser.addRequired('responseSys',@(x) isa(x,'responseSystem'));
            parser.parse(obj,oneLight,pSpot,responseSys);
            
            % Show stimulus
            obj.stimulus.show(oneLight, pSpot);
            
            % Get response
            obj.response = obj.respond(responseSys);
            
            % Process response
            [abort, obj.correct] = obj.processResponse(obj.response);
            if abort
                return;
            end
            
            % Finalize
            obj.done = true;
        end
        function [abort, correct] = processResponse(obj,response)
            correct = false;
            
            % Process response
            if any(strcmpi(response,'abort'))
                % User wants to abort
                abort = true;
                return;
            else
                abort = false;
            end
            
            % Correct? Compare only first response
            correct = all(response{1} == [obj.stimulus.intervals.targetPresent]);        
        end        
    end
    
    methods (Static)
        function response = respond(responseSys)
            % Response interval
            Beeper(500); Beeper(500);
            response = responseSys.waitForResponse();
        end        
    end
end