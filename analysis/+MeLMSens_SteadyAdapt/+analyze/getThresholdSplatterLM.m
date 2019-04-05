function thresholdSplatterLM = getThresholdSplatterLM(acquisition)
% Extract L-M splatter of validated threshold from acquisition
%   
% Syntax:
%   thresholdSplatterLM = getThresholdSplatterLM(acquisition)
%
% Description:
%    Return single L-M contrast value, based on validation measurements
%    taken of nominally threshold stimulus.
%   
% Inputs:
%    acquisition         - scalar MeLMSense_Pulse_acquisition
%
% Outputs:
%    thresholdSplatterLM - scalar numberic LMS contrast based on
%                          validation at threshold

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   extracted MeLMSens_Pulse. analyze.
%                     getThresholdContrastValidated
%                     from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition
%    2019.02.28  jv   Adapted copy into thresholdSplatterLM
%    2019.03.06  jv   copied for MeLMSens_SteadyAdapt

% Check for validations
if ~isempty(acquisition.validationAtThreshold) && ...
        isfield(acquisition.validationAtThreshold,'contrastActual')
    
    % Extract validated contrast at threshold
    validations = acquisition.validationAtThreshold;
    contrastActual = cat(3,validations.contrastActual);
    
    % Convert to LMS
    thresholdSplatterLM = MeLMSens_SteadyAdapt.analyze.LminusMContrastFromBipolarReceptorContrasts(contrastActual);
else
    thresholdSplatterLM = NaN;
end
end