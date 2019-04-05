function F = sessionFigureFromName(participant, sessionName)
%SESSIONFIGUREFROMNAME Summary of this function goes here
%   Detailed explanation goes here

% History:
%    2019.02.26  jv   copied and adapted for MeLMSens_Pulse. Extracted
%                     plot.export

% Get data
acquisitions = MeLMSens_SteadyAdapt.dataManagement.loadSessionAcquisitionsFromName(participant,sessionName);

% Create figure
F = MeLMSens_SteadyAdapt.plot.sessionFigure(acquisitions);

% Add title
t = annotation(F,'textbox',...
    [0.4 0.97 0.20 0.05],...
    'String',strrep(sprintf('%s %s',participant, sessionName),'_',' '),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'FontSize',25,...
    'LineStyle','none');
end