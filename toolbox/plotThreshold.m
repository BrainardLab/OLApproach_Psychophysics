function thresholdGroup = plotThreshold(threshold, varargin)
%PLOTTHRESHOLD Plot indicator of a threshold on e.g. psychometric function
%   plotThreshold(threshold) plots a dashed vertical line indicating the
%   threshold at x = threshold. Thus, it assumes the threshold is some X
%   value, and Y represents e.g., percent correct. Also places a marker
%   with the threshold value.
%
%   plotThreshold(...,'ax',ax) plots in the specified axes; ax is must be a
%   valid axes-object (i.e., open).
%
%   plotThreshold(...,'criterion',Y) also plots a dashed horizontal line
%   indicatign the criterion value that the threshold is based on. The
%   dashed threshold and indicator lines are drawn only until their point
%   of intersection, and don't extend further upwards or rightwards,
%   respectively. The text marker is plot at the intersect location.
%
%   thresholdGroup = plotThreshold(...) returns a handle a graphics
%   Group-object containing the indicator line(s) and the marker.
%
%   See also getThresholdEstimate, plotStaircaseProportionCorrect,
%   plotPsychometricFunction

% History:
%   2018-11-02  J.Vincent wrote plotThreshold.

% Parse input
parser = inputParser();
parser.addRequired('threshold',@(x)validateattributes(x,{'numeric'},{}));
parser.addParameter('ax',gca,@(x)validateattributes(x,{'matlab.graphics.axis.Axes'},{},'isvalid'));
parser.addParameter('criterion',[],@(x)validateattributes(x,{'numeric'},{}));
parser.KeepUnmatched = true;
parser.parse(threshold, varargin{:});
ax = parser.Results.ax;
criterion = parser.Results.criterion;

parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
parser.parse(threshold, varargin{:});

% Get some required axes properties
color = parser.Results.color;
xlims = xlim();
ylims = ylim();

% Create group
thresholdGroup = hggroup;
thresholdGroup.DisplayName = 'Threshold';

if ~isempty(criterion)
    % Plot criterion line: dashed horizontal linesegment at y = criterion,
    % from the left of the plot up to x = threshold;
    criterionLine = plot(ax,[xlims(1) threshold],criterion*[1 1],...
        '--',...
        'Parent',thresholdGroup,...
        'Color',color,...
        'DisplayName','Criterion line');
    ylims(2) = criterion; % set criterion as top of threshold line segment
end

% Plot threshold line: dashed vertical linesegment at x = threshold; whole
% height of plot, or from the bottom of the plot up to y = criterion if
% specified.
thresholdLine = plot(ax,threshold*[1 1],ylims,...
    '--',...
    'Parent',thresholdGroup,...
    'DisplayName','Threshold line',...
    'Color',color);

% Place text marker
markerText = sprintf('Threshold = %.3f',threshold);
if ~isempty(criterion)
    markerText = sprintf('%s (criterion: %.4f)',markerText,criterion);
end
thresholdMarker = text(ax,threshold,ylims(2),...
    markerText,...
    'Color',color,...
    'FontWeight','bold',...
    'Parent',thresholdGroup);
end

