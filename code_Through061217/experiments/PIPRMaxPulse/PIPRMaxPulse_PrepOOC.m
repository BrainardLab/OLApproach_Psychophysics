%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the cache
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND02';

%% Standard parameters
params.experiment = 'PIPRMaxPulse';
params.experimentSuffix = 'PIPRMaxPulse';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 6;
params.isActive = 1;
params.useAmbient = 1;
params.OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;

% 470 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRBlue';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 475;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.30; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

% 623 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRRed';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 623;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.30; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution
%% MaxMel
params.pegBackground = false;
params.modulationDirection = {'MelanopsinDirected'};
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% Mel shifted background
params.backgroundType = 'BackgroundMaxMel';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxMel';
params.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);

% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxMel.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).backgroundSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differencePrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differenceSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxMel.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);

%% MaxLMS
params.pegBackground = false;
params.modulationDirection = {'LMSDirected'};
params.modulationContrast = {[2/3 2/3 2/3]};
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
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxLMS';
params.modulationDirection = 'LMSDirectedSuperMaxLMS';
params.modulationContrast = [2/3 2/3 2/3];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differencePrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differenceSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxLMS.modulationDirection = 'LMSDirectedSuperMaxLMS';
paramsMaxLMS.cacheFile = ['Cache-' paramsMaxLMS.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS);