function sessionPath = sessionRawPathFromName(participant,sessionName)
% Construct path to session directory from participant name, session name

participantPath = MeLMSens_SteadyAdapt.dataManagement.participantRawPathFromName(participant);
sessionFSEntry = dir(fullfile(participantPath,['*' sessionName]));
sessionPath = fullfile(participantPath, sessionFSEntry.name);
end