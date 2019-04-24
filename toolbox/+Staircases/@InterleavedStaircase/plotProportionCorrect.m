function S = plotProportionCorrect(obj,varargin)
%PLOTPROPORTIONCORRECT Summary of this function goes here
%   Detailed explanation goes here

%% Parse input
parser = inputParser();
parser.addRequired('obj');
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.parse(obj,varargin{:});
ax = parser.Results.ax;
axes(ax); hold on;

%% Get proportionCorrect
[binProportionCorrect, binCenter, binN] = obj.proportionCorrect();

%% Plot
S = Staircases.Plot.proportionCorrect(binProportionCorrect,...
                                      'binN', binN,...
                                      'binCenter',binCenter,...
                                      'ax',ax);
end