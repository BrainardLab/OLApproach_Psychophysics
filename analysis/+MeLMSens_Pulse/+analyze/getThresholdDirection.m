function thresholdDirection = getThresholdDirection(acquisition)
% Get the nominal flicker direction shown at threshold
%   
% Syntax:
%   thresholdDirection = getThresholdDirection(acquisition)
%
% Description:
%    Return the direction nominally corresponding to the stimulus at
%    threshold. Direction is scaled by the nominal threshold estimate.
%   
% Inputs:
%    acquisition         - scalar MeLMSense_Pulse_acquisition
%
% Outputs:
%    thresholdDirection  - scalar OLDirection_Bipolar, the flicker
%                          direction for this acquisition scaled to nominal
%                          LMS threshold contrast
%
% Optional keyword arguments:
%    None.
%
% See also:
%    MeLMSens_Pulse.acquisition.threshold,
%    MeLMSens_Pulse.acquisition.flickerDirection,
%    OLDirection_Bipolar.ScaleToReceptorContrast

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.28  jv   extracted MeLMSens_Pulse. analyze.
%                     getThresholdDirection
%                     from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition

% Get direction, background
direction = acquisition.flickerDirection;
background = acquisition.background;

% Get receptors
receptors = acquisition.receptors;

% Get nominal threshold contrast
thresholdContrastNominal = acquisition.threshold;

% Convert to target scaling receptor contrasts
targetContrasts = thresholdContrastNominal * [1 1 1 0; -1 -1 -1 0]';

% Scale direction to target contrast with background
thresholdDirection = direction.ScaleToReceptorContrast(background,receptors,targetContrasts);
end