%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the cache
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calibration file.  
theCalType = 'BoxDRandomizedLongCableAStubby1_ND02';

%% Standard parameters
params.experiment = 'MaxMelPulsePsychophysics';
params.experimentSuffix = 'MaxMelPulsePsychophysics';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;                 % Assuming dilated pupil
params.isActive = 1;
params.useAmbient = 1;
params.OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;              % Original value 0.01

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution

% MaxMel
%
% Note modulation contrast is typically 2/3 for 400% contrast or 66.66%
% sinusoidal contrast, modulation contrast has been set to 20% for testing
% purposes
params.pegBackground = false;
params.modulationDirection = {'MelanopsinDirected'};
% Was 3.75/5.75 - JR
params.modulationContrast = [4/6];
params.modulationContrast = [4/6];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% Generate Mel shifted background
params.backgroundType = 'BackgroundMaxMel';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
params.primaryHeadRoom = 0.01;          % Original value: 0.005
params.backgroundType = 'BackgroundMaxMel';
params.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
params.modulationContrast = [4/6];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);

% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxMel.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).backgroundSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differencePrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differenceSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end

% Save the modulations
paramsMaxMel.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);

%% MaxLMS
params.pegBackground = false;
params.modulationDirection = {'LMSDirected'};
params.modulationContrast = {[4/6 4/6 4/6]};
params.whichReceptorsToIsolate = {[1 2 3]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [1];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% LMS shifted background
params.backgroundType = 'BackgroundMaxLMS';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
params.primaryHeadRoom = 0.01;              % Original value 0.005
params.backgroundType = 'BackgroundMaxLMS';
params.modulationDirection = 'LMSDirectedSuperMaxLMS';
params.modulationContrast = [4/6 4/6 4/6];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);

% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differencePrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differenceSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end

% Save the cache
paramsMaxLMS.modulationDirection = 'LMSDirectedSuperMaxLMS';
paramsMaxLMS.cacheFile = ['Cache-' paramsMaxLMS.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS);

%% Light flux
%
% For the light flux, we'd like a background that is the average
% chromaticity between the two MaxMel and MaxLMS backgrounds. The
% appropriate chromaticities are (approx.):
%   x = 0.54, y = 0.38

% Get the cal files
cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName, [], getpref('OneLight', 'OneLightCalData'));
cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');

% Modulation 
desiredChromaticity = [0.54 0.38];
modPrimary = OLInvSolveChrom(cal, desiredChromaticity);

% Background
%
% This 5 here is hard coding the fact that we want a 400% light flux
% modulation.
bgPrimary = modPrimary/5;

% We copy over the information from the LMS cache file
cacheDataMaxPulseLightFlux = cacheDataMaxLMS;
paramsMaxPulseLightFlux = paramsMaxLMS;

% Set up the cache structure
olCacheMaxPulseLightFlux = OLCache(cacheDir, cal);

% Replace the values
for observerAgeInYrs = [20:60]
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).backgroundPrimary = bgPrimary;
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).backgroundSpd = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).differencePrimary = modPrimary-bgPrimary;
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).differenceSpd = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationPrimarySignedPositive = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationSpdSignedPositive = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end

% Save the cache?
paramsMaxPulseLightFlux.modulationDirection = 'LightFluxMaxPulse';
paramsMaxPulseLightFlux.cacheFile = ['Cache-' paramsMaxPulseLightFlux.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxPulseLightFlux, olCacheMaxPulseLightFlux, paramsMaxPulseLightFlux);