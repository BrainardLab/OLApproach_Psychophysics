function [acquisitions, metadata] = loadSessionAcquisitionsFromName(participant,sessionName)
%LOADSESSIONFROMNAME Summary of this function goes here
%   Detailed explanation goes here
sessionPath = sessionPathFromName(participant, sessionName);
[acquisitions, metadata] = loadSessionAcquisitionsFromPath(sessionPath);
end