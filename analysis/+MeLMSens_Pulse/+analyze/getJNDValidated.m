function JNDValidated = getJNDValidated(acquisition)
% Extract validated LMS JND form acquisition
%   
% Syntax:
%   JNDValidated = getJNDValidated(acquisition)
%
% Description:
%    Return single LMS just-noticeable-difference, based on validation
%    measurements taken of nominally threshold stimulus.
%   
% Inputs:
%    acquisition  - scalar MeLMSense_Pulse_acquisition
%
% Outputs:
%    JNDValidated - scalar numberic JND based on validation at threshold

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.28  jv   extracted MeLMSens_Pulse. analyze.
%                     getJNDValidated
%                     from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition

% Check for validations
if ~isempty(acquisition.validationAtThreshold) && ...
        isfield(acquisition.validationAtThreshold,'contrastActual')
    
    % Extract validations
    validations = acquisition.validationAtThreshold;
    
    % Extract receptor excitations
    excitation = cat(3,validations.excitationActual);
    
    % Average over validations
    excitation = mean(excitation,3);
    
    % Extract difference (direction-background) in receptor excitations
    excitationDiff = excitation(:,4:5);    
    
    % Convert to JND
    JNDValidated = MeLMSens_Pulse.analyze.excitationDiffToJND(excitationDiff);
else
    JNDValidated = NaN;
end
end