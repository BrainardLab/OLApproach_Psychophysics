function draw(obj,varargin)
% Add central white spot and black annulus to a GLWindow
%
% Syntax:
%   projectorWindow = projectSpot;
%
% Description:
%
%
% Inputs:
%    projectorSpot - 
% 
% Outputs:
%    None.             projectorWindow now has objects defining a white
%                      (RGB: [1 1 1]) field, a black (RGB: [0 0 0])
%                      annulus, and a white central spot.
%
% Optional key/value arguments:
%    None.
%
% See also:
%    GLWindow, makeProjectorSpot, toggleProjectorSpot

% History:
%    07/16/18  jv  wrote addProjectorSpot;
%    09/01/18  jv  turn into projectorSpot.addSpot method.        


%% Parse input
parser = inputParser;
parser.addRequired('obj');

% Colors
parser.addParameter('annulusRGB',[0 0 0],@isnumeric);
parser.addParameter('spotRGB',[1 1 1],@isnumeric);
parser.addParameter('fixationRGB',[1 0 0],@isnumeric);

% Sizes
parser.addParameter('spotDiameter',160,@isnumeric);
parser.addParameter('annulusDiameter',530,@isnumeric);
parser.addParameter('spotCenter',[0 0],@isnumeric);
parser.addParameter('annulusCenter',[0 0],@isnumeric);

parser.parse(obj, varargin{:});

%% Create child-elements
obj.children('annulus') = projectorSpot.circle('RGB',parser.Results.annulusRGB,...
                               'center',parser.Results.annulusCenter,...
                               'diameter',parser.Results.annulusDiameter,...
                               'name','annulus');
obj.children('spot') = projectorSpot.circle('RGB',parser.Results.spotRGB,...
                            'center',parser.Results.spotCenter,...
                            'diameter',parser.Results.spotDiameter,...
                            'name','spot');
obj.children('tfixation') = projectorSpot.circle('RGB',parser.Results.fixationRGB,...
                            'center',parser.Results.spotCenter,...
                            'diameter',16,...
                            'name','fixation');

%% Get GLWindow
projectorWindow = obj.projectorWindow;

%% Add objects
projectorWindow.addRectangle([0 0], projectorWindow.SceneDimensions, obj.fieldRGB);
for c = obj.children.values()
    child = c{:};
    child.draw(projectorWindow);
end
end