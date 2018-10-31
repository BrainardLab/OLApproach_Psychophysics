function sessionPath = sessionPathFromName(participant,sessionName)
% Construct path to session directory from participant name, session name

rawDataPath = getpref('MeLMSens','ProtocolDataRawPath');
participantPath = fullfile(rawDataPath,participant);
sessionFSEntry = dir(fullfile(participantPath,['*' sessionName]));
sessionPath = fullfile(participantPath, sessionFSEntry.name);
end