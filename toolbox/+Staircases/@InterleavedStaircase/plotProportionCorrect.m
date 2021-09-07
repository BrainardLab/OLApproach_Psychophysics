function S = plotProportionCorrect(obj,varargin)
%PLOTPROPORTIONCORRECT Summary of this function goes here
%   Detailed explanation goes here

%% Parse input
parser = inputParser();
parser.addRequired('obj');
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.addParameter('threshold',[]);
parser.addParameter('criterion',[]);
parser.KeepUnmatched=true;
parser.parse(obj,varargin{:});
ax = parser.Results.ax;
parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
parser.parse(obj,varargin{:});

threshold = parser.Results.threshold;
criterion = parser.Results.criterion;

axes(ax); hold on;

%% Get proportionCorrect
[binProportionCorrect, binCenter, binN] = obj.proportionCorrect();

%% Plot proportion correct
S = Staircases.Plot.proportionCorrect(binProportionCorrect,...
                                      'binN', binN,...
                                      'binCenter',binCenter,...
                                      'color',parser.Results.color,...
                                      'ax',ax);
                                  
%% Plot threshold         
if ~isempty(threshold)
    color = ax.ColorOrder(ax.ColorOrderIndex-1,:); % reuse same color as proportionCorrect
    Staircases.Plot.thresholdProportionCorrect(threshold,'ax',ax,'color',color,'criterion',criterion);
end
end