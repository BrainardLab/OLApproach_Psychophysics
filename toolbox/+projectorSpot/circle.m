classdef circle < handle
    %CIRCLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        name;
        RGB = [1 1 1];
        center = [0 0];
        diameter = 100; 
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
        
        function add(obj,projectorWindow)
            projectorWindow.addOval(obj.center, [obj.diameter obj.diameter], obj.RGB,'Name',obj.name);            
        end
    end
end