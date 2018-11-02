function hg = plotPFThreshold(psychometricFunction, PFParams, criterion,varargin)
%PLOTPFTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here

% Parse input
parser = inputParser();
parser.addRequired('psychometricFunction',@(x)validateattributes(x,{'function_handle'},{}));
parser.addRequired('PFParams',@(x)validateattributes(x,{'numeric'},{}));
parser.addRequired('criterion',@(x)validateattributes(x,{'numeric'},{}));
parser.addParameter('ax',gca,@(x)validateattributes(x,{'matlab.graphics.axis.Axes'},{},'isvalid'));
parser.parse(psychometricFunction,PFParams, criterion,varargin{:});
ax = parser.Results.ax;

% Get threshold
threshold = thresholdFromPsychometricFunction(psychometricFunction,PFParams,criterion);

% Get some required axes properties
color = ax.ColorOrder(ax.ColorOrderIndex,:);
xlims = xlim();
ylims = ylim();

% Create group
hg = hggroup;
hg.DisplayName = 'Threshold';

% Plot criterion line: dashed horizontal linesegment at y = criterion, from
% the left of the plot up to x = threshold;
criterionLine = plot([xlims(1) threshold],criterion*[1 1],...
    '--',...
    'Parent',hg,...
    'Color',color,...
    'DisplayName','Criterion line');

% Plot threshold line: dashed vertical linesegment at x = threshold, from
% the bottom of the plot up to y = criterion;
thresholdLine = plot(threshold*[1 1],[ylims(1) criterion],...
    '--',...
    'Parent',hg,...
    'DisplayName','Threshold line',...
    'Color',color);

% Place text marker
thresholdMarker = text(threshold,criterion,...
    sprintf('Threshold = %.3f (criterion: %.3f)',threshold,criterion),...
    'Parent',hg);
end