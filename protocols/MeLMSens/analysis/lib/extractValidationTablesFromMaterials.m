function [luminancesBg, contrastsBg, contrastsFlicker] = extractValidationTablesFromMaterials(materials)
%EXTRACTVALIDATIONSFROMMATERIALS Summary of this function goes here
%   Detailed explanation goes here

% Three sets of validations: pre-corrections, post-corrections,
% post-experiment. Convert each to sets of tables, append column with label:
[luminancesBgPre, contrastsBgPre, contrastsFlickerPre] = validationsToTablesMeLMSens_SteadyAdapt(materials.validationsPre);
luminancesBgPre = addvarString(luminancesBgPre,'PreCorrection','VariableName','label');
contrastsBgPre = addvarString(contrastsBgPre,'PreCorrection','VariableName','label');
contrastsFlickerPre = addvarString(contrastsFlickerPre,'PreCorrection','VariableName','label');

[luminancesBgPostCorrection, contrastsBgPostCorrection, contrastsFlickerPostCorrection] = validationsToTablesMeLMSens_SteadyAdapt(materials.validationsPostCorrection);
luminancesBgPostCorrection = addvarString(luminancesBgPostCorrection,'PostCorrection','VariableName','label');
contrastsBgPostCorrection = addvarString(contrastsBgPostCorrection,'PostCorrection','VariableName','label');
contrastsFlickerPostCorrection = addvarString(contrastsFlickerPostCorrection,'PostCorrection','VariableName','label');

[luminancesBgPostSession, contrastsBgPostSession, contrastsFlickerPostSession] = validationsToTablesMeLMSens_SteadyAdapt(materials.validationsPostSession);
luminancesBgPostSession = addvarString(luminancesBgPostSession,'PostSession','VariableName','label');
contrastsBgPostSession = addvarString(contrastsBgPostSession,'PostSession','VariableName','label');
contrastsFlickerPostSession = addvarString(contrastsFlickerPostSession,'PostSession','VariableName','label');

% Concatenate
luminancesBg = vertcat(luminancesBgPre, luminancesBgPostCorrection, luminancesBgPostSession);
contrastsBg = vertcat(contrastsBgPre, contrastsBgPostCorrection, contrastsBgPostSession);
contrastsFlicker = vertcat(contrastsFlickerPre, contrastsFlickerPostCorrection, contrastsFlickerPostSession);
end