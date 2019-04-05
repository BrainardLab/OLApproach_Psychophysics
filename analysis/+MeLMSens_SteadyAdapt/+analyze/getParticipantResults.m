function resultsTable = getParticipantResults(participant)
% Extract results from participant specified by name
%   
% Syntax:
%   resultsTable = getParticipantResults(participant)
%
% Description:
%    From all sessions by specified participant, extract the nominal and
%    validated LMS threshold contrast.
%   
% Inputs:
%    participant  - scalar string / char-array specified participant
%
% Outputs:
%    resultsTable - table(), with variables 'name', 'pedestalPresent',
%                   'thresholdContrastNominal',
%                   'thresholdContrastValidated'
%
% See also:
%    MeLMSens_Pulse.analyze.getSessionResults,
%    MeLMSens_Pulse.dataManagement.listParticipants,
%    MeLMSens_Pulse.dataManagement.listSessions,

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getParticpantResults
%    2019.03.06  jv   adapted for MeLMSens_SteadyAdapt

% Get session names
sessionNames = MeLMSens_SteadyAdapt.dataManagement.listSessions(participant);

% Initialize table
resultsTable = table();

% Loop over sessions
for sessionName = sessionNames
    sessionName = sessionName{:}; % de-cellify
    T = MeLMSens_SteadyAdapt.analyze.getSessionResultsFromName(participant, sessionName);
    T = addvarString(T,[string(participant) string(sessionName)],...
                        'VariableNames',{'participant','session'}); % add participant,session identifier
    T = T(:,[end-1:end, 1:end-2]); % pre-pend identifiers
    
    resultsTable = vertcat(resultsTable, T); % append to results table
end