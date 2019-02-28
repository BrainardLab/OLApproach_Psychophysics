function LminusMContrast = LminusMContrastFromBipolarReceptorContrasts(receptorContrasts)
% Calculate single L-M contrast from set(s) of bipolar receptor contrasts
%   
% Syntax:
%   LminusMContrast = LminusMContrastFromBipolarReceptorContrasts(receptorContrasts)
%
% Description:
%    Calculate from set of individual receptor contrasts, a single LMS
%    contrast value. Averages bipolar receptor contrasts (with positive and
%    negative components), as well as any number of sets of (bipolar)
%    contrasts
%
%    Mostly just to have a documented, version-controlled, definition of
%    LMS contrast.
% 
% Inputs:
%    receptorContrasts - numeric of at least 3xNxM receptor contrasts.
%                        Assumes rows 1:3 correspond to L, M, S-cone
%                        contrast. Assumes that N is 2 for bipolar
%                        contrast, and M is number of sets of contrasts
%                        (although these assumptions can be violated, since
%                        it's just a grand average).
%
% Outputs:
%    LminusMContrast   - scalar numeric of mean LMS contrast

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   Extracted MeLMSens_Pulse. analyze.
%                     LMSContrastFromBipolarReceptorContrasts from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition.
%    2019.02.28  jv   Adapted copy into LminusMContrast

% Convert negative contrast to positive
receptorContrasts = abs(receptorContrasts);

% If array has a 3rd dimension (i.e., sets of bipolar contrasts), average
% over those
receptorContrasts = mean(receptorContrasts,3);

% Extract first three rows, i.e., L, M
receptorContrasts = receptorContrasts(1:2,:);

% Average over positive and negative components
receptorContrasts = mean(receptorContrasts,2);

% Subtract to get L-M
LminusMContrast = receptorContrasts(1)-receptorContrasts(2);
end