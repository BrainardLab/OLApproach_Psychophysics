classdef projectorSpot < handle
    %PROJECTORSPOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        isOn = false;
        fullScreen = false;
        
        % Colors
        backgroundRGB = [0 0 0];
        annulusRGB = [0 0 0];
        fieldRGB = [1 1 1];
        spotRGB = [1 1 1];

        % Geometry
        spotDiameter = 160;
        annulusDiameter = 530;
        spotCenter = [0 0];
        annulusCenter = [0 0];
    end
    properties (Access = protected)
        projectorWindow;        
        isOpen = false;
        children = containers.Map();
    end

    methods
        function obj = projectorSpot(varargin)           
            %% make projectorWindow
            obj.makeProjectorWindow(varargin{:});
            
            %% Add spot
            obj.addSpot;
            
            %% Show
            obj.show;
        end
        
        function delete(obj)
            obj.close();
        end
        
        function show(obj)
            % Toggles a projector spot on
            %
            % Syntax:
            %   spot.show
            %   show(spot)
            %
            % Description:
            %    Detailed explanation goes here
            %
            % Inputs:
            %    obj  - projectorSpot object
            %
            % Outputs:
            %    None. - Objects defining projector spot have now been
            %            enabled.
            %
            % Optional key/value arguments:
            %    None.
            %
            % See also:
            %    projectorSpot, projectorSpot.hide, projectorSpot.toggle, 
            %    GLWindow

            % History:
            %    07/17/18  jv   wrote toggleProjectorSpot.
            %    09/01/18  jv   turn into projectorSpot.show method.  
            if ~obj.isOpen
                obj.open();
                obj.addSpot();
            end
            obj.projectorWindow.enableAllObjects();
            obj.projectorWindow.draw();
            obj.isOn = true;
        end
        
        function hide(obj)
            % Toggles a projector spot on
            %
            % Syntax:
            %   spot.hide
            %   hide(spot)
            %
            % Description:
            %    Detailed explanation goes here
            %
            % Inputs:
            %    obj  - projectorSpot object
            %
            % Outputs:
            %    None. - Objects defining projector spot have now been
            %            disabled.
            %
            % Optional key/value arguments:
            %    None.
            %
            % See also:
            %    projectorSpot, projectorSpot.show, projectorSpot.toggle, 
            %    GLWindow

            % History:
            %    07/17/18  jv   wrote toggleProjectorSpot.
            %    09/01/18  jv   turn into projectorSpot.hide method.               
            obj.open();
            obj.isOn = false;
            obj.projectorWindow.disableAllObjects();
            obj.projectorWindow.draw();
        end
        
        function close(obj)
            obj.projectorWindow.close();
            obj.isOn = false;            
            obj.isOpen = false;
        end              
        
        function isOn = toggle(obj)
            % Toggles a projector spot on or off
            %
            % Syntax:
            %   spot.toggle();
            %   isOn = spot.toggle();
            %
            % Description:
            %    Detailed explanation goes here
            %
            % Inputs:
            %    obj  - projectorSpot object
            %
            % Outputs:
            %    isOn - scalar boolean, projectorSpot.isOn property after
            %           toggle
            %
            % Optional key/value arguments:
            %    None.
            %
            % See also:
            %    projectorSpot, projectorSpot.show, projectorSpot.hide, 
            %    GLWindow

            % History:
            %    07/17/18  jv   wrote toggleProjectorSpot.
            %    09/01/18  jv   turn into projectorSpot.toggle method.
            %                   Remove 'toggleOn' arg, deprecated by
            %                   show/hide methods.
            if ~obj.isOn
                obj.show();
            else
                obj.hide();
            end
            isOn = obj.isOn;
        end
    end
    
    methods (Access = protected)       
        function projectorWindow = makeProjectorWindow(obj, varargin)
            % Create GLWindow to control display
            %
            % Syntax:
            %   projectorWindow = makeProjectorWindow;
            %
            % Description:
            %
            %
            % Inputs:
            %    None.
            % 
            % Outputs:
            %    projectorWindow - GLWindow, open on last display
            %
            % Optional key/value arguments:
            %    None.
            %
            % See also:
            %    projectorSpot, projectorSpot.makeSpot, projectorSpot.open
            %    projectorSpot.close

            % History:
            %    07/16/18  jv  wrote makeProjectorSpot.
            %    09/01/18  jv  turn into projectorSpot.makeProjectorWindow
            %                  method.                
            displayInfo = mglDescribeDisplays;
            lastDisplay = length(displayInfo);
            
            %% Parse input
            parser = inputParser;
            parser.addParameter('WindowID',lastDisplay,@isnumeric);
            parser.addParameter('fullscreen',false,@islogical);
            parser.addParameter('BackgroundColor',[0 0 0],@isnumeric);
            parser.addParameter('SceneDimensions',displayInfo(lastDisplay).screenSizePixel);
            parser.addParameter('WindowPosition',[0 0],@isnumeric);
            parser.addParameter('WindowSize',[300 300],@isnumeric);
            parser.parse(varargin{:});
            
            %% Create a GLWindow object
            screenSizeInPixels = displayInfo(lastDisplay).screenSizePixel;
            projectorWindow = GLWindow('SceneDimensions', screenSizeInPixels, ...
                'BackgroundColor', parser.Results.BackgroundColor,...
                'WindowID',        parser.Results.WindowID,...
                'Fullscreen',      parser.Results.fullscreen,...
                'WindowPosition',  parser.Results.WindowPosition,...
                'WindowSize',      parser.Results.WindowSize);   
            obj.projectorWindow = projectorWindow;
            obj.fullScreen = parser.Results.fullscreen;
        end  
        
        function open(obj)
            %    09/03/18  jv   spoofFullScreen before opening. Workaround
            %                   for R2018a mgl issues.            
            mglSetParam('spoofFullScreen',1);            
            try
                obj.projectorWindow.open();
            catch E
                obj.projectorWindow.close();
                rethrow(E);
            end
            obj.isOpen = true;
        end        
    end
end