function [acquisitions, metadata] = loadSessionAcquisitionsFromPath(sessionPath)
%LOADSESSION Summary of this function goes here
%   Detailed explanation goes here

acquisitions = containers.Map();
metadata = containers.Map();

% Dummy staircase for proper constructor initialization
S = Staircase('standard',.05,[1],[1],[1]);

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

end