function exportAllSessionFigures()
% Export a session figure PDF for all sessions of all participants
%   
% Syntax:
%   exportAllSessionFigures()
%
% Description:
%    From all sessions by all participants, export a figure with the
%    staircases of each acquisition separately, and the psychometric
%    function fits.
%   
% Inputs:
%    None.
%
% Outputs:
%    Mone.
%
% See also:
%    MeLMSens_Pulse.plot.exportSessionFigureFromName,
%    MeLMSens_Pulse.dataManagement.listParticipants,
%    MeLMSens_Pulse.dataManagement.listSessions,

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getAllResults
%    2019.03.20  jv   adapted copy to exportAllSessionFigures

% Get participant names
participantNames = MeLMSens_Pulse.dataManagement.listParticipants();

% Loop over participants
for participant = participantNames
    participant = participant{:}; % de-cellify
    fprintf('Exporting figures for %s...\n',participant);
    
    sessionNames = MeLMSens_Pulse.dataManagement.listSessions(participant);
    for session = sessionNames
        session = session{:};
        fprintf('\t%s',session);
        MeLMSens_Pulse.plot.exportSessionFigureFromName(participant,session);
        fprintf('done.\n');
    end
    fprintf('done.\n');
end
end