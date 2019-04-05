function thresholdContrastValidated = getThresholdContrastValidated(acquisition)
% Extract validated LMS threshold contrast form acquisition
%   
% Syntax:
%   thresholdContrastValidated = getThresholdContrastValidated(acquisition)
%
% Description:
%    Return single LMS contrast value, based on validation measurements
%    taken of nominally threshold stimulus.
%   
% Inputs:
%    acquisition                - scalar MeLMSense_Pulse_acquisition
%
% Outputs:
%    thresholdContrastValidated - scalar numberic LMS contrast based on
%                                 validation at threshold

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   extracted MeLMSens_Pulse. analyze.
%                     getThresholdContrastValidated
%                     from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition

% Check for validations
if ~isempty(acquisition.validationAtThreshold) && ...
        isfield(acquisition.validationAtThreshold,'contrastActual')
    
    % Extract validated contrast at threshold
    validations = acquisition.validationAtThreshold;
    contrastActual = cat(3,validations.contrastActual);
    
    % Convert to LMS
    thresholdContrastValidated = MeLMSens_Pulse.analyze.LMSContrastFromBipolarReceptorContrasts(contrastActual);
else
    thresholdContrastValidated = NaN;
end
end