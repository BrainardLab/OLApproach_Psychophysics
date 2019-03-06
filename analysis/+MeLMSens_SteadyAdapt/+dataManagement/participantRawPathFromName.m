function participantRawPath = participantRawPathFromName(participant)
% Construct path to session directory from participant name, session name

dataRawPath = getpref('MeLMSens_SteadyAdapt','ProtocolDataRawPath');
participantRawPath = fullfile(dataRawPath,participant);
end