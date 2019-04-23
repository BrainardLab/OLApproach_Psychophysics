function thresholdTrialSeries(threshold, varargin)
%THRESHOLDTRIALSERIES plots a horizontal line given threshold value(s)
%   thresholdTrialSeries(threshold) plot a horizontal dashed line at the
%   given threshold value. If threshold is a row-vector, plots horizontal
%   dashed lines at each threshold value.
%
%   thresholdTrialSeries(threshold, ax) plots threshold lines in the
%   specified axes.

% History:
%   2018.10.29  J.Vincent wrote plotStaircase.
%   2019.04.23  J.Vincent extracted Plot.thresholdTrialSeries

%% Parse input
parser = inputParser;
parser.addRequired('threshold',@(x) isempty(x) || isnumeric(x));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.KeepUnmatched = true;
parser.parse(threshold, varargin{:});
ax = parser.Results.ax;

%% Plot
% Draw a dashed horizontal line at the threshold value
hold on;
plot(ax,repmat(xlim',[1,numel(threshold)]),repmat(threshold,[2 1]),'--');
hold off;
end