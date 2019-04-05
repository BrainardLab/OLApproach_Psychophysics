classdef circle < handle
    %CIRCLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        RGB = [1 1 1];
        center = [0 0];
        diameter = 100; 
    end
    properties
        window;
    end
    properties (Dependent)
        isDrawn;
        Visible;
    end
    
    methods
        % isDrawn == does the window have this object in queue?
        function isDrawn = get.isDrawn(obj)
            if isempty(obj.window)
                isDrawn = false;
            else
                isDrawn = obj.window.findObjectIndex(obj.name) ~= -1;
            end
        end
        function set.isDrawn(obj,draw)
            if draw
                obj.window.addOval(obj.center, [obj.diameter obj.diameter], obj.RGB,'Name',obj.name);
            else
                obj.window.deleteObject(obj.name);
            end
            obj.window.draw();
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
            if obj.isDrawn
                obj.window.getObjectProperty(obj.name,'Enabled',false);
            end
            obj.Visible = visible;
        end
        
        % RGB
        function RGB = get.RGB(obj)
            if obj.isDrawn
                obj.RGB = obj.window.getObjectProperty(obj.name,'Color');
            end
            RGB = obj.RGB;
        end
        function set.RGB(obj, RGB)
            if obj.isDrawn
                obj.window.setObjectProperty(obj.name,'Color',RGB)
                obj.window.draw();
            end
            obj.RGB = RGB;            
        end
        
        % Center
        function center = get.center(obj)
            if obj.isDrawn
                obj.center = obj.window.getObjectProperty(obj.name,'Center');
            end
            center = obj.center;
        end
        function set.center(obj, center)
            if obj.isDrawn
                obj.window.setObjectProperty(obj.name,'Center',center)
                obj.window.draw();
            end
            obj.center = center;            
        end  
        
        % Diameter
        function diameter = get.diameter(obj)
            if obj.isDrawn
                obj.diameter = mean(obj.window.getObjectProperty(obj.name,'Dimensions'));
            end
            diameter = obj.diameter;
        end
        function set.diameter(obj, diameter)
            if obj.isDrawn
                obj.window.setObjectProperty(obj.name,'Dimensions',[diameter diameter])
                obj.window.draw();
            end
            obj.diameter = diameter;            
        end
    end
    
    methods
        function obj = circle(varargin)
            %CIRCLE Construct an instance of this class
            %   Detailed explanation goes here
            
            %% Parse input
            parser = inputParser();
            parser.addParameter('name','');
            parser.addParameter('RGB',[1 1 1],@(x)validateattributes(x,{'numeric'},{'row','size',[1 3],'nonnegative','<=',1}));
            parser.addParameter('center',[0 0],@(x)validateattributes(x,{'numeric'},{'row','size',[1 2],'finite','real'}));
            parser.addParameter('diameter',100,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative','finite','real'}));
            parser.parse(varargin{:});
            
            %% Set params
            % Find parameters for which we're not using the defaults:
            overwrites = setdiff(parser.Parameters,['obj',parser.UsingDefaults]);

            % Assign to obj.properties
            for p = overwrites
                obj.(p{:}) = parser.Results.(p{:});
            end
        end
        
        function draw(obj,window)
            obj.window = window;
            
            % Does the circle already exist? If not, add it.
            if obj.window.findObjectIndex(obj.name) == -1
                obj.window.addOval(obj.center, [obj.diameter obj.diameter], obj.RGB,'Name',obj.name);
            end
            
            % Set properties
            obj.window.setObjectProperty(obj.name,'Dimensions',[obj.diameter, obj.diameter]);
            obj.window.setObjectProperty(obj.name,'Center',obj.center);
            obj.window.setObjectProperty(obj.name,'Color',obj.RGB);
            obj.window.setObjectProperty(obj.name,'Name',obj.name);
            obj.window.draw();
        end
        
        function delete(obj)
            obj.isDrawn = false;
        end
    end
end