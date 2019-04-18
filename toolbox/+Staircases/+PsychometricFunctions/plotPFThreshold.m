function thresholdGroup = plotPFThreshold(psychometricFunction, PFParams, criterion,varargin)
%PLOTPFTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here

% Parse input
parser = inputParser();
parser.addRequired('psychometricFunction',@(x)validateattributes(x,{'function_handle'},{}));
parser.addRequired('PFParams',@(x)validateattributes(x,{'numeric'},{}));
parser.addRequired('criterion',@(x)validateattributes(x,{'numeric'},{}));
parser.addParameter('ax',gca,@(x)validateattributes(x,{'matlab.graphics.axis.Axes'},{},'isvalid'));
parser.KeepUnmatched = true;
parser.parse(psychometricFunction,PFParams, criterion,varargin{:});
ax = parser.Results.ax;
parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
parser.parse(psychometricFunction,PFParams, criterion,varargin{:});
color = parser.Results.color;

% Get threshold
threshold = thresholdFromPsychometricFunction(psychometricFunction,PFParams,criterion);

% Plot
thresholdGroup = plotThreshold(threshold,'criterion',criterion,'ax',ax,'color',color);
end