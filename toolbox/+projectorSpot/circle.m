classdef circle < projectorSpot.windowObject
    %CIRCLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RGB = [1 1 1];
        center = [0 0];
        diameter = 100;
    end
    
    methods        
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
        function obj = circle(name,varargin)
            %CIRCLE Construct an instance of this class
            %   Detailed explanation goes here
            
            %% Parse input
            parser = inputParser();
            parser.addRequired('name');
            parser.addParameter('window',[]);
            parser.addParameter('Visible',false);            
            parser.addParameter('RGB',[1 1 1],@(x)validateattributes(x,{'numeric'},{'row','size',[1 3],'nonnegative','<=',1}));
            parser.addParameter('center',[0 0],@(x)validateattributes(x,{'numeric'},{'row','size',[1 2],'finite','real'}));
            parser.addParameter('diameter',100,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative','finite','real'}));
            parser.parse(name,varargin{:});
            
            %% Set params
            % Set name
            obj.name = parser.Results.name;
            
            % Find parameters for which we're not using the defaults:
            overwrites = setdiff(parser.Parameters,['obj',parser.UsingDefaults]);
            
            % Assign to obj.properties
            for p = overwrites
                obj.(p{:}) = parser.Results.(p{:});
            end
        end
        
        function draw(obj)
            % Assert that we have a window to draw on
            assert(~isempty(obj.window),'No window specified');
            
            % Does the circle already exist? If not, add it.
            if ~obj.isDrawn
                obj.window.addOval(obj.center, [obj.diameter obj.diameter], obj.RGB,'Name',obj.name);
            end
            
            % Set properties
            obj.window.setObjectProperty(obj.name,'Dimensions',[obj.diameter, obj.diameter]);
            obj.window.setObjectProperty(obj.name,'Center',obj.center);
            obj.window.setObjectProperty(obj.name,'Color',obj.RGB);
            obj.window.setObjectProperty(obj.name,'Name',obj.name);
            obj.window.setObjectProperty(obj.name,'Enabled',obj.Visible);
            obj.window.draw();
        end
    end
end