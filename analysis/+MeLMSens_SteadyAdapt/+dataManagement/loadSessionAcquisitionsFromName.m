function [acquisitions, metadata] = loadSessionAcquisitionsFromName(participant,sessionName)
%LOADSESSIONFROMNAME Summary of this function goes here
%   Detailed explanation goes here
sessionPath = MeLMSens_SteadyAdapt.dataManagement.sessionRawPathFromName(participant, sessionName);
[acquisitions, metadata] = MeLMSens_SteadyAdapt.dataManagement.loadSessionAcquisitionsFromPath(sessionPath);
end