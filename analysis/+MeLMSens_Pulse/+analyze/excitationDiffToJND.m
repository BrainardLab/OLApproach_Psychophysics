function JND = excitationDiffToJND(excitationDiff)
% Convert receptor excitation differences to LMS JND
%   
% Syntax:
%   JND = excitationDiffToJND(excitationDiff)
%
% Description:
%    Convert matrix of receptor excitation differences (as direction -
%    background) at threshold, to just-noticeable-difference of LMS
%    excitation. Assumes first three rows of matrix are L, M, S cone
%    excitations. Average any number of vectors excitation differences,
%    e.g., average over positive and negative component of bipolar
%    contrast.
%
% Inputs:
%    excitationDiff - numeric matrix, at least 3xN, with N vectors of
%                     excitation differences between direction(s) and
%                     background, at threshold. Assumes rows 1:3 are L, M,
%                     S excitation differences.
%
% Outputs:
%    JND            - scalar numeric, the average of LMS excitation across
%                     all vectors.

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   extracted MeLMSens_Pulse. analyze.
%                     excitationDiffToJND from MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition

% Convert to absolute differences in receptor excitation
excitationDiff_abs = abs(excitationDiff);

% Average over postive/negative components
excitationDiff_mean = mean(excitationDiff_abs,2);

% Extract only L, M, S
excitationDiff_mean_LMS = excitationDiff_mean(1:3);

% JND as mean of L, M, S excitation differences
JND = mean(excitationDiff_mean_LMS);
end