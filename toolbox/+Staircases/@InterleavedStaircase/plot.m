function ax = plot(obj,varargin)
% Plot all trials of this acquisition

% Parse input
parser = inputParser();
parser.addRequired('obj');
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.parse(obj,varargin{:});
ax = parser.Results.ax;
axes(ax); hold on;

% Plot staircases trialseries
Staircases.Plot.stimulusLevelsCorrects(obj.stimulusLevels,obj.corrects,...
                                        'ax',ax,...
                                        'UserData',obj);

% % Plot mean threshold
% color = ax.ColorOrder(ax.ColorOrderIndex,:); % current plot color, which we'll reuse)
% plot(xlim,obj.threshold*[1 1],'--','Color',color);
% text(10,obj.threshold+0.001,...
%     sprintf('Fit threshold = %.3f',mean(obj.threshold)),...
%     'Color',color,...
%     'FontWeight','bold');

% Finish up labeling
ylabel('Stimulus Level');
ylim([obj.stimulusMin,obj.stimulusMax]);
title('Staircase trials');
hold off;
end