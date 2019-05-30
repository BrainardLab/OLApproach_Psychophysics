function ax = plotTrialSeries(obj,varargin)
% Plot all trials of this acquisition

% Parse input
parser = inputParser();
parser.addRequired('obj');
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.addParameter('threshold',[]);
parser.parse(obj,varargin{:});
threshold = parser.Results.threshold;
ax = parser.Results.ax;
axes(ax); hold on;

% Plot staircases trialseries
Staircases.Plot.stimulusLevelsCorrects(obj.stimulusLevels,obj.corrects,...
                                        'ax',ax,...
                                        'UserData',obj);

% Plot threshold
Staircases.Plot.thresholdTrialSeries(threshold,'ax',ax);
end