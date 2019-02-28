function sessionPath = sessionProcessedPathFromName(participant,sessionName)
% Construct path to session directory from participant name, session name

dataRawPath = getpref('MeLMSens_Pulse','ProtocolDataProcessedPath');
participantPath = fullfile(dataRawPath,participant);
sessionFSEntry = dir(fullfile(participantPath,['*' sessionName]));
sessionPath = fullfile(participantPath, sessionFSEntry.name);
end