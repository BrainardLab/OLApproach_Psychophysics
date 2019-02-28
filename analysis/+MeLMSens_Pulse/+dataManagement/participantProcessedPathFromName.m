function participantProcessedPath = participantProcessedPathFromName(participant)
% Construct path to session directory from participant name, session name

dataProcessedPath = getpref('MeLMSens_Pulse','ProtocolDataProcessedPath');
participantProcessedPath = fullfile(dataProcessedPath,participant);
end