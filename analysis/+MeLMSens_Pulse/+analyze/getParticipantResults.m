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

% Get session names
sessionNames = MeLMSens_Pulse.dataManagement.listSessions(participant);

% Initialize table
resultsTable = table();

% Loop over sessions
for sessionName = sessionNames
    sessionName = sessionName{:}; % de-cellify
    T = MeLMSens_Pulse.analyze.getSessionResultsFromName(participant, sessionName);
    T = addvarString(T,sessionName,'VariableNames',{'session'}); % add session identifier
    T = T(:,[end, 1:end-1]); % pre-pend session identifier
    
    resultsTable = vertcat(resultsTable, T); % append to results table
end