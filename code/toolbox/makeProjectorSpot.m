function projectorWindow = makeProjectorSpot(varargin)
% Create GLWindow with central white spot and black annulus to project 
%
% Syntax:
%   projectorWindow = makeProjectorSpot;
%
% Description:
%
%
% Inputs:
%    None.
% 
% Outputs:
%    projectorWindow - GLWindow, open on last display, with objects
%                      defining a white (RGB: [1 1 1]) field, a black (RGB:
%                      [1 1 1]) annulus, and a white central spot, on a
%                      black background.
%
% Optional key/value arguments:
%    None.
%
% See also:
%    GLWindow, addProjectorSpot, toggleProjectorSpot

% History:
%    07/16/18  jv  wrote it.

%% Parse input
parser = inputParser;
displayInfo = mglDescribeDisplays;
lastDisplay = length(displayInfo);
parser.addParameter('WindowID',lastDisplay,@isnumeric);
parser.addParameter('Fullscreen',false,@islogical);
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
    'Fullscreen',      parser.Results.Fullscreen,...
    'WindowPosition',  parser.Results.WindowPosition,...
    'WindowSize',      parser.Results.WindowSize);

%% Add spot
addProjectorSpot(projectorWindow);
end