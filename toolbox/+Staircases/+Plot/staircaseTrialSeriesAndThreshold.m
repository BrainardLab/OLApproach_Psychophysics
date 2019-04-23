function ax = staircaseTrialSeriesAndThreshold(staircase, threshold, varargin)
%PLOTSTAIRCASETRIALSERIES Plot values of (array of) staircase object(s)
%   plotStaircaseTrialseries(staircase) plot the values of the staircase in
%   order of appearance as a solid line. Incorrect trials are marked with
%   an asterisk marker. Threshold estimate is indicate with a horizontal
%   dashed line at that value.
%
%   plotStaircaseTrialseries(staircases) plots multiple staircases in the
%   same axes, each in a different color.
%
%   plotStaircaseTrialseries(staircases,threshold) plots a horizontal
%   dashed line indicated the given threshold value. If no threshold value
%   is supplied, the getThresholdEstimate(staircase) method is used. If
%   multiple staircases are provided, threshold must be a vector of
%   numel(staircases).
%
%   plotStaircaseTrialseries(...,'ax',ax) plot in the specified axes; ax is
%   must be a valid axes-object (i.e., open). Default plots in the current
%   axes, i.e., ax = gca().
%
%   ax = plotStaircaseTrialseries(...) returns a handle to the axes-object
%   containing the plot.
%
%   This function tries to forward unmatched input arguments to plot(),
%   although no guarantee is made that those will work well.
%
%   See also getThresholdEstimate, plotStaircaseProportionCorrect

% History:
%   2018.10.29  J.Vincent wrote plotStaircase.
%   2019.04.24  J.Vincent extracted Plot.staircaseTrialSeries,
%                         Plot.thresholdTrialSeries

%% Parse input
parser = inputParser;
parser.addRequired('staircase',@(x)isa(x,'Staircase'));
parser.parse(staircase); % First check if staircase is valid (correct class)

% As default, getThresholEstimates for staircase
for k = 1:numel(staircase)
    threshold(k) = getThresholdEstimate(staircase(k));
end
% Allow caller to override threshold with value (or empty)
parser.addOptional('threshold',threshold,@(x) isempty(x) || numel(x) == numel(staircase));

parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.KeepUnmatched = true;
parser.parse(staircase, threshold, varargin{:});
ax = parser.Results.ax;
threshold = parser.Results.threshold;

%% Plot each staircase
Staircases.Plot.staircaseTrialSeries(staircase,'ax',ax);

%% Plot threshold-lines
if ~isempty(threshold)
    % Decrement axis.ColorOrderIndex by k (number of staircase plotted) to
    % get the same color dashed line as the solid line of all values
    if ax.ColorOrderIndex > 1
        ax.ColorOrderIndex = ax.ColorOrderIndex-k;
    end
    
    % Call threshold plotting routine
    Staircases.Plot.thresholdTrialSeries(threshold);
end
end