function resultsTable = getAllResults()
% Extract results from all participants
%   
% Syntax:
%   resultsTable = getAllResults()
%
% Description:
%    From all sessions by all participants, extract the nominal and
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
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getAllResults
%    2019.03.06  jv   adapted for MeLMSens_SteadyAdapt, quick threshold

% Get participant names
participantNames = MeLMSens_SteadyAdapt.dataManagement.listParticipants();

% Initialize table
resultsTable = table();

% Loop over sessions
for participant = participantNames
    participant = participant{:}; % de-cellify
    fprintf('Extract results for %s...',participant);
    T = MeLMSens_SteadyAdapt.analyze.getParticipantResults(participant);
    
    resultsTable = vertcat(resultsTable, T); % append to results table
    fprintf('done.\n');
end
end