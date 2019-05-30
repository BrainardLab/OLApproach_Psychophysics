function CLUT = make(varargin)
%MAKECLUT Summary of this function goes here
%   Detailed explanation goes here

%% Parse input
parser = inputParser;
parser.addOptional('background',[.5 .5 .5]);
parser.addOptional('stepSize',1/255);
parser.addOptional('NSteps',10);
parser.parse(varargin{:});

%% Define RGBs to measure
% Background
background = parser.Results.background;

% Step size: 
% 1 in RGB range [0,255], so 1/255 in range [0,1]
stepSize = parser.Results.stepSize;

% Range = 0 +- NSteps
NSteps = parser.Results.NSteps;
range = (-NSteps:1:NSteps)';

% RGBs
CLUT = stepSize * range * [1 1 1] + background;

end