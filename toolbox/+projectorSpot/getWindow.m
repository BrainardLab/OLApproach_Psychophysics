function projectorWindow = getWindow(varargin)
% Create GLWindow to control display
%
% Syntax:
%   projectorWindow = getWindow();
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
%    04/05/19  jv  extracted from class into package function

displayInfo = mglDescribeDisplays;
windowID = length(displayInfo);

%% Parse input
parser = inputParser;
parser.addParameter('WindowID',windowID,@isnumeric);
parser.addParameter('fullscreen',false,@islogical);
parser.addParameter('BackgroundColor',[0 0 0],@isnumeric);
parser.addParameter('SceneDimensions',displayInfo(windowID).screenSizePixel);
parser.addParameter('WindowPosition',[0 0],@isnumeric);
parser.addParameter('WindowSize',[300 300],@isnumeric);
parser.parse(varargin{:});

%% Open
projectorWindow = GLWindow('SceneDimensions', parser.Results.SceneDimensions, ...
    'BackgroundColor', parser.Results.BackgroundColor,...
    'WindowID',        parser.Results.WindowID,...
    'Fullscreen',      parser.Results.fullscreen,...
    'WindowPosition',  parser.Results.WindowPosition,...
    'WindowSize',      parser.Results.WindowSize);
mglSetParam('spoofFullScreen',1);
end