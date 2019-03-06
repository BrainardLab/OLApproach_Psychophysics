function participantProcessedPath = participantProcessedPathFromName(participant)
% Construct path to session directory from participant name, session name

dataProcessedPath = getpref('MeLMSens_SteadyAdapt','ProtocolDataProcessedPath');
participantProcessedPath = fullfile(dataProcessedPath,participant);
end