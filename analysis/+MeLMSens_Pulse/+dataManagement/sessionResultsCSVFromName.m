function outputPath = sessionResultsCSVFromName(participant, sessionName)
% Export results from session specified by name to CSV file
%
% Syntax:
%   sessionResultsCSVFromName(participant, sessionName)
%   outputPath = sessionResultsCSVFromName(participant, sessionName)
%
% Description:
%    Export results from session as CSV at specified filepath.
%
% Inputs:
%    participant - scalar string / char-array specified participant
%    sessionName - scalar string / char-array specifying session. Will be
%                  partially matched.
%
% Outputs:
%    outputPath  - scalar string with full filepath to output CSV file
%
% See also:
%    MeLMSens_Pulse.analyze.getSessionResultsFromName,
%    MeLMSens_Pulse.dataManagement.listParticipants,
%    MeLMSens_Pulse.dataManagement.listSessions,

% History:
%    2019.02.27  jv   wrote MeLMSens_Pulse. dataManagement.
%                     resultsCSVFromName

% Get results
sessionResults = MeLMSens_Pulse.analyze.getSessionResultsFromName(participant, sessionName);

% Add session metadata
sessionResults = addvarString(sessionResults,[string(participant) string(sessionName)],...
             'VariableNames',{'participant','session'});
sessionResults = sessionResults(:,[end-1:end, 1:end-2]);
         
% Outputpath
sessionProcessedPath = MeLMSens_Pulse.dataManagement.sessionProcessedPathFromName(participant, sessionName);
filename = sprintf('%s-%s.results.csv',sessionName,participant);
outputPath = fullfile(sessionProcessedPath, filename);

% Ensure directory exists
outputFileDir = fileparts(outputPath);
if ~isempty(outputFileDir) && ~isfolder(outputFileDir)
    mkdir(outputFileDir)
end

% Write
writetable(sessionResults,outputPath);
end