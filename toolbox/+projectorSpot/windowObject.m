classdef windowObject < handle
    %WINDOWOBJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        window;
        Visible;
    end
    properties (Dependent)
        isDrawn;
    end
    
    methods % Getters/setters
        % isDrawn == does the window have this object in queue?
        function isDrawn = get.isDrawn(obj)
            if isempty(obj.window)
                isDrawn = false;
            else
                isDrawn = obj.window.findObjectIndex(obj.name) ~= -1;
            end
        end
        function set.isDrawn(obj,draw)
            if ~obj.isDrawn
                return;
            end
            if draw
                % Redraw object by calling draw method
                obj.draw();
            else
                % Remove object from draw queue
                obj.window.deleteObject(obj.name);
                
                % Redraw window
                obj.window.draw();
            end
        end
        
        % Visible
        function Visible = get.Visible(obj)
            if ~obj.isDrawn
                Visible = false;
            else
                Visible = obj.window.getObjectProperty(obj.name,'Enabled');
            end
        end
        function set.Visible(obj,visible)
            obj.Visible = visible;
            if obj.isDrawn
                obj.window.setObjectProperty(obj.name,'Enabled',visible);
                obj.draw();
            end
        end
    end
    
    methods
        function delete(obj)
            % Setting obj.isDrawn to 'false' triggers removal from queue
            obj.isDrawn = false;
        end
        function s = struct(obj)
            s = builtin('struct',obj);
            s.window = struct(s.window);
        end
    end
    
    methods (Abstract)
        draw(obj)
    end
end