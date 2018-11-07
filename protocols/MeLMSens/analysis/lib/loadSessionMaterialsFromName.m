function materials = loadSessionMaterialsFromName(participant,sessionName)
%LOADSESSIONFROMNAME Summary of this function goes here
%   Detailed explanation goes here
sessionPath = sessionPathFromName(participant, sessionName);
materialsFilename = sessionMaterialFileFromName(participant,sessionName);
materialsFile = dir(fullfile(sessionPath,materialsFilename));
materials = load(fullfile(materialsFile.folder, materialsFile.name));
end