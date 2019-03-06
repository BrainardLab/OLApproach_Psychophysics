function resultsTable = getSessionResultsFromName(participant,sessionName)
% Extract results from session specified by name
%   
% Syntax:
%   resultsTable = getSessionResultsFromName(participant,sessionName)
%
% Description:
%    From a session specified by participant and session name, extract the
%    nominal and validated LMS threshold contrast.
%   
% Inputs:
%    participant  - scalar string / char-array specified participant
%    sessionName  - scalar string / char-array specifying session. Will be
%                   partially matched.
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
%    MeLMSens_Pulse.dataManagement.loadSessionAcquisitionsFromName

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getSessionResults
%    2019.03.06  jv   copied for MeLMSens_SteadyAdapt

session = MeLMSens_SteadyAdapt.dataManagement.loadSessionAcquisitionsFromName(participant, sessionName);
resultsTable = MeLMSens_SteadyAdapt.analyze.getSessionResults(session);
end