function validationsCSVsFromName(participant, sessionName, outputFileDir)
%MATERIALSMATTOVALIDATIONSCSVS Summary of this function goes here
%   Detailed explanation goes here

%% Load materials
materials = loadSessionMaterialsFromName(participant,sessionName);

%% Extract validation tables
[luminancesBg, contrastsBg, contrastsFlicker] = extractValidationTablesFromMaterials(materials);

%% Save
if ~isfolder(outputFileDir)
    mkdir(outputFileDir)
end
writetable(luminancesBg,fullfile(outputFileDir,sprintf('%s-%s-luminancesBackgrounds.csv',participant,sessionName)));
writetable(contrastsBg,fullfile(outputFileDir,sprintf('%s-%s-contrastsBackgrounds.csv',participant,sessionName)));
writetable(contrastsFlicker,fullfile(outputFileDir,sprintf('%s-%s-contrastsFlicker.csv',participant,sessionName)));
end