classdef projectorSpot < handle
    %PROJECTORSPOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        isOn = false;
        fullScreen = false;
        
        % Colors
        fieldRGB = [1 1 1];
        backgroundRGB = [0 0 0];
    end
    properties (Dependent)
        % Colors
        annulusRGB;
        spotRGB;
        fixationRGB;

        % Geometry
        spotDiameter;
        annulusDiameter;
        spotCenter;
        annulusCenter;
        center;
    end
    properties (Access = protected)
        projectorWindow;        
        isOpen = false;
        children = containers.Map();
    end

    methods
        function obj = projectorSpot(varargin)           
            %% make projectorWindow
            obj.projectorWindow = projectorSpot.projectorWindow();
            
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
                obj.draw();
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
   
    methods % Getters
        function annulusRGB = get.annulusRGB(obj)
            annulusRGB = obj.children('annulus').RGB;
        end
        function spotRGB = get.spotRGB(obj)
            spotRGB = obj.children('spot').RGB;
        end
        function fixationRGB = get.fixationRGB(obj)
            fixationRGB = obj.children('tfixation').RGB;
        end
        function spotDiameter = get.spotDiameter(obj)
            spotDiameter = obj.children('spot').diameter;
        end
        function annulusDiameter = get.annulusDiameter(obj)
            annulusDiameter = obj.children('annulus').diameter;
        end
        function spotCenter = get.spotCenter(obj)
            spotCenter = obj.children('spot').center;
        end
        function annulusCenter = get.annulusCenter(obj)
            annulusCenter = obj.children('annulus').center;
        end
        function center = get.center(obj)
            center = [obj.spotCenter; obj.annulusCenter];
        end
    end
    
    methods % Setters
        function set.annulusRGB(obj, RGB)
            annulus = obj.children('annulus');
            annulus.RGB = RGB;
            annulus.draw(obj.projectorWindow);
        end
        function set.annulusDiameter(obj, diameter)
            annulus = obj.children('annulus');
            annulus.diameter = diameter;
            annulus.draw(obj.projectorWindow);
        end
        function set.annulusCenter(obj, center)
            annulus = obj.children('annulus');
            annulus.center = center;
            annulus.draw(obj.projectorWindow);
        end
        
         function set.spotRGB(obj, RGB)
            spot = obj.children('spot');
            spot.RGB = RGB;
            spot.draw(obj.projectorWindow);
         end
        function set.fixationRGB(obj, RGB)
            fixation = obj.children('tfixation');
            fixation.RGB = RGB;
            fixation.draw(obj.projectorWindow);
        end
        function set.spotDiameter(obj, diameter)
            spot = obj.children('spot');
            spot.diameter = diameter;
            spot.draw(obj.projectorWindow);
        end
        function set.spotCenter(obj, center)
            spot = obj.children('spot');
            fixation = obj.children('tfixation');
            spot.center = center;
            fixation.center = center;
            spot.draw(obj.projectorWindow);
            fixation.draw(obj.projectorWindow);
        end       
        
        function set.center(obj, center)
            obj.spotCenter = center(1,:);
            obj.annulusCenter = center(2,:);
        end
    end
    
    methods (Access = protected)         
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