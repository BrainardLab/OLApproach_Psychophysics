function sessionPath = sessionProcessedPathFromName(participant,sessionName)
% Construct path to session directory from participant name, session name

participantPath = MeLMSens_Pulse.dataManagement.participantProcessedPathFromName(participant);
sessionFSEntry = dir(fullfile(participantPath,['*' sessionName]));
sessionPath = fullfile(participantPath, sessionFSEntry.name);
end