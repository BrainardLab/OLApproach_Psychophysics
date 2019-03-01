function LMSContrast = LMSContrastFromBipolarReceptorContrasts(receptorContrasts)
% Calculate single LMS contrast from set(s) of bipolar receptor contrasts
%   
% Syntax:
%   LMSContrast = LMSContrastFromBipolarReceptorContrasts(receptorContrasts)
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
%    LMSContrast       - scalar numeric of mean LMS contrast

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   Extracted MeLMSens_Pulse. analyze.
%                     LMSContrastFromBipolarReceptorContrasts from
%                     MeLMSens_SteadyAdapt. extractResultsFromAcquisition.

% Convert negative contrast to positive
receptorContrasts = abs(receptorContrasts);

% If array has a 3rd dimension (i.e., sets of bipolar contrasts), average
% over those
receptorContrasts = mean(receptorContrasts,3);

% Extract first three rows, i.e., L, M, S
receptorContrasts = receptorContrasts(1:3,:);

% Average over positive and negative components
receptorContrasts = mean(receptorContrasts,2);

% Average over L, M, S to get LMS
LMSContrast = mean(receptorContrasts,1);
end