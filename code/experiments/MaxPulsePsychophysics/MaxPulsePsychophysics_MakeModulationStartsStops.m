%MaxPulsePsychophysics_MakeModulationStartsStops
%
% Description:
%   This script reads in the primaries for the modulations in the experiment and computes the starts stops.
%   Typically, we only generate the primaries for the extrema of the modulations, so this routine is also responsible
%   for filling in the intermediate contrasts (by scaling the primaries) and then taking each of these through the 
%   calibration file to get the arrays of starts and stops that are cached for the experimental program.
%
%   This calculation is subject and data specific.  It is subject specific
%   because the primaries depend on age specific receptor fundamentals.  Is
%   is date specific because we often do spectrum seeking.
%
%    The output is cached in the directory specified by
%    getpref('MaxPulsePsychophysics','ModulationStartsStopsDir');

% 6/18/17  dhb  Added descriptive comment.

% Ask for the observer ID and age
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

% Calibration type
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND02';
params.experiment =  'MaxPulsePsychophysics';

% LMS; Melanopsin; Light Flux
tic;
customSuffix = ['_' observerID '_' todayDate];
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, customSuffix, params);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, customSuffix, params);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, customSuffix, params);
toc;
