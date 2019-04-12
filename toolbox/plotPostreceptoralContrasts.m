function plotPostreceptoralContrasts(LMS,LminusM,varargin)
%PLOTPOSTRECEPTORALCONTRASTS Summary of this function goes here
%   Detailed explanation goes here

%% Parse input
parser = inputParser;
parser.addRequired('LMS');
parser.addRequired('LminusM');
parser.addParameter('ax',gca);
parser.parse(LMS,LminusM,varargin{:});

ax = parser.Results.ax;

%% Plot
plot(ax,LMS,LminusM);

%% Adjust axes
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.YAxis.Exponent = 0;
ax.YAxis.TickDirection = 'both';
ax.XAxis.Exponent = 0;
ax.XAxis.TickDirection = 'both';
xlim([-max(abs(xlim)),max(abs(xlim))]);
ylim([-max(abs(ylim)),max(abs(ylim))]);
ax.Box = 'off';

%% Label
xlabel('(L+M+S)/3 contrast');
xlabel('(L+M+S)/3 contrast')
ylabel('L-M contrast')
end