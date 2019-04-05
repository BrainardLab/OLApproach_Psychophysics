function [luminancesBg, contrastsBg, contrastsFlicker] = extractValidationTablesFromMaterials(materials)
%EXTRACTVALIDATIONSFROMMATERIALS Summary of this function goes here
%   Detailed explanation goes here

% Three sets of validations: pre-corrections, post-corrections,
% post-experiment. Convert each to sets of tables, append column with label:
luminancesBg = [];
contrastsBg = [];
contrastsFlicker = [];

if isfield(materials,'validationsPre')
    [luminancesBgPre, contrastsBgPre, contrastsFlickerPre] = validationsToTablesMeLMSens_SteadyAdapt(materials.validationsPre);
    luminancesBgPre = addvarString(luminancesBgPre,'PreCorrection','VariableName',"label");
    contrastsBgPre = addvarString(contrastsBgPre,'PreCorrection','VariableName',"label");
    contrastsFlickerPre = addvarString(contrastsFlickerPre,'PreCorrection','VariableName',"label");
    luminancesBg = vertcat(luminancesBg, luminancesBgPre);
    contrastsBg = vertcat(contrastsBg, contrastsBgPre);
    contrastsFlicker = vertcat(contrastsFlicker, contrastsFlickerPre);
end

if isfield(materials,'validationsPostCorrection')
    [luminancesBgPostCorrection, contrastsBgPostCorrection, contrastsFlickerPostCorrection] = validationsToTablesMeLMSens_SteadyAdapt(materials.validationsPostCorrection);
    luminancesBgPostCorrection = addvarString(luminancesBgPostCorrection,'PostCorrection','VariableName',"label");
    contrastsBgPostCorrection = addvarString(contrastsBgPostCorrection,'PostCorrection','VariableName',"label");
    contrastsFlickerPostCorrection = addvarString(contrastsFlickerPostCorrection,'PostCorrection','VariableName',"label");
    luminancesBg = vertcat(luminancesBg, luminancesBgPostCorrection);
    contrastsBg = vertcat(contrastsBg, contrastsBgPostCorrection);
    contrastsFlicker = vertcat(contrastsFlicker, contrastsFlickerPostCorrection);
end

if isfield(materials,'validationsPostSession')
    [luminancesBgPostSession, contrastsBgPostSession, contrastsFlickerPostSession] = validationsToTablesMeLMSens_SteadyAdapt(materials.validationsPostSession);
    luminancesBgPostSession = addvarString(luminancesBgPostSession,'PostSession','VariableName',"label");
    contrastsBgPostSession = addvarString(contrastsBgPostSession,'PostSession','VariableName',"label");
    contrastsFlickerPostSession = addvarString(contrastsFlickerPostSession,'PostSession','VariableName',"label");
    luminancesBg = vertcat(luminancesBg, luminancesBgPostSession);
    contrastsBg = vertcat(contrastsBg, contrastsBgPostSession);
    contrastsFlicker = vertcat(contrastsFlicker, contrastsFlickerPostSession);
end
end