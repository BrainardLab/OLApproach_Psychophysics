function [acquisitions, materials, metadata] = loadSessionFromPath(sessionPath)
%LOADSESSION Summary of this function goes here
%   Detailed explanation goes here

acquisitions = containers.Map();
metadata = containers.Map();

% Load acquisitions
acquisitionNames = ["Mel_low","Mel_high","LMS_low","LMS_high"];
for a = acquisitionNames
    metadatum = struct();
    metadatum.name = a;
    metadatum.datafileName = "data-*-" + a + ".mat";
    metadatum.datafile = dir(fullfile(sessionPath,metadatum.datafileName));
    tmp = load(fullfile(metadatum.datafile.folder,metadatum.datafile.name));
    metadatum.acquisition = tmp.acquisition;
    metadata(char(a)) = metadatum;
    acquisitions(char(a)) = metadatum.acquisition;
end

% Load materials
materialsFilename = sprintf("materials-*.mat");
materialsFile = dir(fullfile(sessionPath,materialsFilename));
materials = load(fullfile(materialsFile.folder, materialsFile.name));
end