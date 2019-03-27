function S = plotStaircaseProportionCorrect(staircase,varargin)
%PLOTSTAIRCASEPROPORTIONCORRECT Plot proportion correct resonses of (array of) staircase object(s)
%   plotStaircaseProportionCorrect(staircase) plot proportion correct as a
%   scatterplot. Data are binned, and markers are placed indicating the
%   proportion correct at x = mean value for that bin.
%
%   plotStaircaseProportionCorrect(staircase,'binSize',N) calculates
%   proportion correct over N trials per bin.
%
%   plotStaircaseProportionCorrect(staircases) plots the aggregation of
%   multiple staircases in the same scatterplot, i.e., collapses over
%   staircases.
%
%   plotStaircaseProportionCorrect(...,'ax',ax) plot in the specified axes;
%   ax is must be a valid axes-object (i.e., open).
%
%   S = plotStaircaseProportionCorrect(...) returns a handle to the
%   scatter-object containing the scatterplot.
%
%   This function tries to forward unmatched input arguments to scatter(),
%   although no guarantee is made that those will work well.
%
%   See also plotStaircaseTrialSeries, plotThreshold,
%   plotPsychometricFunction, getThresholdEstimate

% History:
%   2018.11.02  J.Vincent wrote plotStaircaseProportionCorrect.
%   2019.03.27  J.Vincent farmed out calculations to other functions

%% Parse input
parser = inputParser;
parser.addRequired('staircase',@(x)isa(x,'Staircase'));
parser.parse(staircase);
parser.addParameter('threshold',[],@(x) numel(x) == numel(staircase));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.addParameter('binSize',15);
parser.KeepUnmatched = true;
parser.parse(staircase, varargin{:});
ax = parser.Results.ax;

%% Get binned data
[binProportionCorrect,binCenter,binN] = staircaseProportionCorrect(staircase);

%% Plot
hold(ax,'on');
S = scatter(ax,binCenter,binProportionCorrect,...
    (binN+1)*10,... % size is 10 * number of trials in bin
    'filled',...
    'DisplayName','Aggregated proportion correct');
end