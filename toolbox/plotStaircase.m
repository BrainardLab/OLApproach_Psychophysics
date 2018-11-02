function ax = plotStaircase(staircase, varargin)
%PLOTSTAIRCASE Plot values of (array of) staircase object(s)
%   plotStaircase(staircase) plot the values of the staircase in order of
%   appearance as a solid line. Incorrect trials are marked with an
%   asterisk marker. Threshold estimate is indicate with a horizontal
%   dashed line at that value.
%
%   plotStaircase(staircases) plots multiple staircases in the same axes,
%   each in a different color.
%
%   plotStaircase(...,'ax',ax) plot in the specified axes; ax is must be a
%   valid axes-object (i.e., open).
%
%   ax = plotStaircase(...) returns a handle to the axes-object containing
%   the plot.
%
%   plotStaircase(...,'threshold',threshold) plots a horizontal dashed line
%   indicated the given threshold value. If no threshold value is supplied,
%   the getThresholdEstimate(staircase) method is used. If multiple
%   staircases are provided, threshold must be a vector of
%   numel(staircases).
%
%   This function tries to forward unmatched input arguments to plot(),
%   although no guarantee is made that those will work well.
%
%   See also getThresholdEstimate, plotStaircaseProportionCorrect

% History:
%   2018-10-29  J.Vincent wrote plotStaircase.

%% Parse input
parser = inputParser;
parser.addRequired('staircase',@(x)isa(x,'Staircase'));
parser.parse(staircase);
parser.addParameter('threshold',[],@(x) numel(x) == numel(staircase));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.KeepUnmatched = true;
parser.parse(staircase, varargin{:});
ax = parser.Results.ax;

if isempty(parser.Results.threshold)
    for k = 1:numel(staircase)
        threshold(k) = getThresholdEstimate(staircase(k));
    end
else
    threshold = parser.Results.threshold;
end

%% Extract values, correct/incorrect
for k = 1:numel(staircase)
    [value(:,k), correct(:,k)] = getTrials(staircase(k));
end
correct = logical(correct);

%% Plot
hold(ax,'on');
for k = 1:size(value,2)
    
    % Plot values for all trials of staircase
    % Plot all values in a contiguous solid line.
    % Place markers only at trials where response was incorrect
    plot(ax,value(:,k),'-*','MarkerIndices',find(~correct(:,k)),'MarkerSize',10,parser.Unmatched);
    
    % Plot threshold estimate for staircase
    % Draw a dashed horizontal line at the value of the threshold estimate
    % Decrement axis.ColorOrderIndex by 1 to get the same color dashed line
    % as the solid line of all values
    if ax.ColorOrderIndex > 1
        ax.ColorOrderIndex = ax.ColorOrderIndex-1;
    end
    plot(ax,xlim,threshold(k)*[1 1],'--');
end
xlabel(ax,'Trial number');
ylabel(ax,'Value');
end