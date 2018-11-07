function sessionFig(participant,sessionName)
%SESSIONSTRIALSFIGS Summary of this function goes here
%   Detailed explanation goes here

% Get figure
sessionPath = sessionPathFromName(participant,sessionName);
acquisitions = loadSessionAcquisitionsFromPath(sessionPath);
fig = plotSessionTrials(acquisitions);

% Add title
t = annotation(fig,'textbox',...
    [0.4 0.97 0.20 0.05],...
    'String',strrep(sprintf('%s %s',participant, sessionName),'_',' '),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'FontSize',25,...
    'LineStyle','none');

% Print to PDF
fig.PaperOrientation = 'landscape';
fig.PaperPositionMode = 'auto';
outputPath = strrep(sessionPath,'raw','processed');
filename = fullfile(outputPath,sprintf('%s_%s.trials.pdf',participant,sessionName));
print('-fillpage',filename,'-dpdf');
end