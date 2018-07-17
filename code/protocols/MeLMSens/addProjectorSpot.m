function addProjectorSpot(projectorWindow,varargin)
% Add central white spot and black annulus to a GLWindow
%
% Syntax:
%   projectorWindow = projectSpot;
%
% Description:
%
%
% Inputs:
%    projectorWindow - 
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
%    07/16/18  jv  wrote it.


%% Parse input
parser = inputParser;
parser.addRequired('projectorWindow');

% Colors
parser.addParameter('backgroundRGB',[0 0 0],@isnumeric);
parser.addParameter('annulusRGB',[0 0 0],@isnumeric);
parser.addParameter('fieldRGB',[1 1 1],@isnumeric);
parser.addParameter('spotRGB',[1 1 1],@isnumeric);

% Sizes
parser.addParameter('spotDiameter',130,@isnumeric);
parser.addParameter('annulusDiameter',590,@isnumeric);
parser.addParameter('centerPosition',[0 0],@isnumeric);

parser.parse(projectorWindow, varargin{:});

%% Add objects
projectorWindow.addRectangle(parser.Results.centerPosition, projectorWindow.SceneDimensions, parser.Results.fieldRGB, 'Name', 'field');
projectorWindow.addOval(parser.Results.centerPosition, [parser.Results.annulusDiameter parser.Results.annulusDiameter], parser.Results.annulusRGB, 'Name', 'annulusOuterCircle');
projectorWindow.addOval(parser.Results.centerPosition, [parser.Results.spotDiameter parser.Results.spotDiameter], parser.Results.spotRGB, 'Name', 'centralSpot');
end