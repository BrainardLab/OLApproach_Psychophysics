function ax = staircaseTrialSeries(staircase, varargin)
%STAIRCASETRIALSERIES Plot values of (array of) staircase object(s)
%   staircaseTrialseries(staircase) plot the values of the staircase in
%   order of appearance as a solid line. Incorrect trials are marked with
%   an asterisk marker.
%
%   staircaseTrialseries(staircases) plots multiple staircases in the
%   same axes, each in a different color.
%
%   staircaseTrialseries(...,'ax',ax) plot in the specified axes; ax is
%   must be a valid axes-object (i.e., open). Default plots in the current
%   axes, i.e., ax = gca().
%
%   ax = plotStaircaseTrialseries(...) returns a handle to the axes-object
%   containing the plot.
%
%   See also Staircases.staircaseStimulusLevelsCorrects

% History:
%   2018.10.29  J.Vincent wrote plotStaircase.
%   2019.04.24  J.Vincent extracted Plot.staircaseTrialSeries,
%                         Plot.thresholdTrialSeries

%% Parse input
parser = inputParser;
parser.addRequired('staircase',@(x)isa(x,'Staircase'));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.KeepUnmatched = true;
parser.parse(staircase, varargin{:});
ax = parser.Results.ax;

%% Get stimulus levels, corrects
[stimulusLevels, corrects] = Staircases.staircaseStimulusLevelsCorrects(staircase);

%% Plot each staircase
Staircases.Plot.stimulusLevelsCorrects(stimulusLevels,corrects,'ax',ax);
ylim([staircase.stimulusMin, stimulusMax]);
end