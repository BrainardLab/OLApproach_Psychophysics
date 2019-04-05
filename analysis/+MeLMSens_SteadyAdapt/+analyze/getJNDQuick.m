function JNDNominal = getJNDQuick(acquisition)
% Extract nominal LMS JND form acquisition
%   
% Syntax:
%   JNDNominal = getJNDNominal(acquisition)
%
% Description:
%    Return single nominal LMS just-noticeable-difference
%   
% Inputs:
%    acquisition  - scalar MeLMSense_Pulse_acquisition
%
% Outputs:
%    JNDNominal - scalar numberic JND

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.28  jv   extracted MeLMSens_Pulse. analyze.
%                     getJNDNominal
%                     from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition
%    2019.03.06  jv   adapted for MeLMSens_SteadyAdapt, quick threshold


% Get nominal direction at threshold
thresholdDirection = MeLMSens_SteadyAdapt.analyze.getThresholdQuickDirection(acquisition);

% Get difference (direction - background) of receptor excitation at
% threshold
[~,~,excitationDiff] = thresholdDirection.ToDesiredReceptorContrast(acquisition.background, acquisition.receptors);

% Convert to JND
JNDNominal = MeLMSens_SteadyAdapt.analyze.excitationDiffToJND(excitationDiff);

end

