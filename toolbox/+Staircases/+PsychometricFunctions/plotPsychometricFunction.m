function PFLine = plotPsychometricFunction(psychometricFunction, PFParams, X, varargin)
%PLOTPSYCHOMETRICFUNCTION Plot smooth curve of fitted psychometric function
%   plotPsychometricFunction(psychometricFunction, PFParams, X) plots a
%   smooth curve of the given psychometric function with the given params,
%   in the domain given by vector X.
%
%   plotPsychometricFunction(...,'ax',ax) plots in the specified axes; ax
%   is must be a valid axes-object (i.e., open). Default plots in the
%   current axes, i.e., ax = gca().
%
%   PFLine = plotPsychometricFunction(...) returns a handle to the
%   Line-object of the psychometric function plot.
%
%   See also plotStaircaseProportionCorrect, plotThreshold

% History:
%   2018-11-02  J.Vincent wrote plotPsychometricFunction.

% Parse input
parser = inputParser();
parser.addRequired('psychometricFunction',@(x)validateattributes(x,{'function_handle'},{}));
parser.addRequired('PFParams',@(x)validateattributes(x,{'numeric'},{}));
parser.addRequired('X',@(x)validateattributes(x,{'numeric'},{}));
parser.addParameter('ax',gca,@(x)validateattributes(x,{'matlab.graphics.axis.Axes'},{},'isvalid'));
parser.KeepUnmatched = true;
parser.parse(psychometricFunction,PFParams,X,varargin{:});
ax = parser.Results.ax;

% Make a smooth curve with the parameters for all contrast
% levels
axes(ax); hold on;
probabilityCorrectPF = psychometricFunction(PFParams,X);
PFLine = plot(ax,X,probabilityCorrectPF,'DisplayName',[func2str(psychometricFunction) ' fit line'],parser.Unmatched);

% Label
title(ax,func2str(psychometricFunction));
ylabel(ax,'Response');
xlabel(ax,'Stimulus value');
end