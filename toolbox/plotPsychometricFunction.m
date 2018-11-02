function PFLine = plotPsychometricFunction(psychometricFunction, PFParams, x, varargin)
%PLOTPSYCHOMETRICFUNCTION Summary of this function goes here
%   Detailed explanation goes here

% Parse input
parser = inputParser();
parser.addRequired('psychometricFunction',@(x)validateattributes(x,{'function_handle'},{}));
parser.addRequired('PFParams',@(x)validateattributes(x,{'numeric'},{}));
parser.addRequired('x',@(x)validateattributes(x,{'numeric'},{}));
parser.addParameter('ax',gca,@(x)validateattributes(x,{'matlab.graphics.axis.Axes'},{},'isvalid'));
parser.KeepUnmatched = true;
parser.parse(psychometricFunction,PFParams,x,varargin{:});
ax = parser.Results.ax;

% Make a smooth curve with the parameters for all contrast
% levels
axes(ax); hold on;
probabilityCorrectPF = psychometricFunction(PFParams,x);
PFLine = plot(ax,x,probabilityCorrectPF,'DisplayName',[func2str(psychometricFunction) ' fit line'],parser.Unmatched);

% Label
title(ax,func2str(psychometricFunction));
ylabel(ax,'Response');
xlabel(ax,'Stimulus value');
end