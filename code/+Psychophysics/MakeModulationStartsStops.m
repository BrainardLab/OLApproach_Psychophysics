function MakeModulationStartsStops(baseParams)
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
% 6/23/17  npc  Dictionarized modulation params


% LMS; Melanopsin; Light Flux
tic;
customSuffix = ['_' baseParams.observerID '_' baseParams.todayDate];
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment.cfg', baseParams.observerAgeInYrs, baseParams.calibrationType, customSuffix, baseParams);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment.cfg', baseParams.observerAgeInYrs, baseParams.calibrationType, customSuffix, baseParams);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment.cfg', baseParams.observerAgeInYrs, baseParams.calibrationType, customSuffix, baseParams);
toc;
