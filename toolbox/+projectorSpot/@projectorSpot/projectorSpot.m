classdef projectorSpot < handle
    %PROJECTORSPOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        window;
        field;
        annulus;
        macular;
        fixation;
    end
    
    methods
        function obj = projectorSpot(varargin)
            parser = inputParser;
            parser.addParameter('window',[]);
            parser.parse(varargin{:});
            
            obj.field = projectorSpot.rectangle('field','RGB',[1 1 1]);
            obj.annulus = projectorSpot.circle('annulus',...
                                               'RGB',[0 0 0],...
                                               'diameter',500);
            obj.macular = projectorSpot.circle('macular',...
                                               'RGB',[1 1 1],...
                                               'diameter',110);
            obj.fixation = projectorSpot.circle('fixation',...
                                               'RGB',[1 0 0],...
                                               'diameter',10);   
                                           
            obj.window = parser.Results.window;                               
        end
        
        function set.window(obj,window)
            % Make sure we're all working on the same window
            obj.field.window = window;
            obj.annulus.window = window;
            obj.macular.window = window;
            obj.fixation.window = window;  
            obj.window = window;
        end
        
        function draw(obj)  
            % Assert that we have a window to draw on
            assert(~isempty(obj.window),'No window specified');
            
            % Open window
            obj.window.open();
            
            % Set size of field to fill window
            obj.field.size = obj.window.SceneDimensions;
            
            % Draw in correct order
            obj.field.draw();
            obj.annulus.draw();
            obj.macular.draw();
            obj.fixation.draw();
        end
        
        function show(obj)
            obj.draw();
            
            % Set visible = true on children
            obj.field.Visible = true;
            obj.annulus.Visible = true;
            obj.macular.Visible = true;
            obj.fixation.Visible = true;
        end
        
        function hide(obj)
            % Set visible = false on children
            obj.field.Visible = false;
            obj.annulus.Visible = false;
            obj.macular.Visible = false;
            obj.fixation.Visible = false;            
        end
        
        function toggle(obj)
            obj.field.Visible = ~obj.field.Visible;
            obj.annulus.Visible = ~obj.annulus.Visible;
            obj.macular.Visible = ~obj.macular.Visible;
            obj.fixation.Visible = ~obj.fixation.Visible;
        end
        
        function close(obj)
            if ~isempty(obj.window)
                obj.window.close();
            end
        end
        
        function delete(obj)
            obj.field.delete();
            obj.annulus.delete();
            obj.macular.delete();
            obj.fixation.delete();
        end
    end
end