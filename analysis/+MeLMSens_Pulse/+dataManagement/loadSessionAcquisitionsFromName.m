function [acquisitions, metadata] = loadSessionAcquisitionsFromName(participant,sessionName)
%LOADSESSIONFROMNAME Summary of this function goes here
%   Detailed explanation goes here
sessionPath = MeLMSens_Pulse.dataManagement.sessionRawPathFromName(participant, sessionName);
[acquisitions, metadata] = MeLMSens_Pulse.dataManagement.loadSessionAcquisitionsFromPath(sessionPath);
end