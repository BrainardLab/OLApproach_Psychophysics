function materialFilename = sessionMaterialFileFromName(participant,sessionName)
%SESSIONMATERIALFILEFROMNAME Summary of this function goes here
%   Detailed explanation goes here
materialFilename = sprintf('materials-%s-%s.mat',participant,sessionName);
end