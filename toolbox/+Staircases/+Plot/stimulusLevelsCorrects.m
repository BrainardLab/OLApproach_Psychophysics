function ax = stimulusLevelsCorrects(stimulusLevels,corrects, varargin)
%PLOTSTIMULUSVALUESCORRECTS Plot stimulus levels, responses of staircases
%   plotStimulusLevelsCorrects(stimulusLevels, corrects) plot the levels of
%   the staircase in order of appearance as a solid line. Incorrect trials
%   are marked with an asterisk marker.
%
%   plotStimulusLevelsCorrects(stimulusLevels,corrects) with multiple
%   columns for different staircases plots each column in the same axes,
%   each in a different color.
%
%   plotStimulusLevelsCorrects(...,'ax',ax) plot in the specified axes; ax
%   is must be a valid axes-object (i.e., open). Default plots in the
%   current axes, i.e., ax = gca().
%
%   ax = plotStimulusLevelsCorrects(...) returns a handle to the
%   axes-object containing the plot.
%
%   This function tries to forward unmatched input arguments to plot(),
%   although no guarantee is made that those will work well.

% History:
%   2018.10.29  J.Vincent wrote plotStaircase.
%   2019.04.16  J.vincent extract plotStimulusLevelsCorrects

%% Parse input
parser = inputParser;
parser.addRequired('stimulusLevels');
parser.addRequired('corrects');
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.KeepUnmatched = true;
parser.parse(stimulusLevels, corrects, varargin{:});
ax = parser.Results.ax;

assert(all(size(stimulusLevels) == size(corrects)),'Inconsistent sizes of input arrays');

%% Plot
hold(ax,'on');
for k = 1:size(stimulusLevels,2)
    % Plot levels for all trials of staircase
    % Plot all levels in a contiguous solid line.
    % Place markers only at trials where response was incorrect
    plot(ax,stimulusLevels(:,k),'-*',...
        'MarkerIndices',find(~corrects(:,k)),...
        'MarkerSize',10,parser.Unmatched);
end
xlabel(ax,'Trial number');
xlim([1 size(stimulusLevels,1)]);
ylabel(ax,'Stimulus level');
ylim([min(stimulusLevels(:)), max(stimulusLevels(:))]);
end