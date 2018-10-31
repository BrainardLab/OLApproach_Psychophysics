function [acquisitions, metadata] = loadSessionFromName(participant,sessionName)
%LOADSESSIONFROMNAME Summary of this function goes here
%   Detailed explanation goes here
sessionPath = sessionPathFromName(participant, sessionName);
[acquisitions, metadata] = loadSessionFromPath(sessionPath);
end

