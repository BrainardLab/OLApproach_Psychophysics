%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the cache
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theCalType = 'BoxBRandomizedLongCableDStubby1_ND02';

%% Standard parameters
params.experiment = 'MelanopsinMRRodControl';
params.experimentSuffix = 'MelanopsinMRRodControl';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin,Rods';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution
%% MaxMel
params.pegBackground = false;
params.modulationDirection = {'MelanopsinDirectedRodControl'};
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[5]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% Mel shifted background
params.backgroundType = 'BackgroundMaxMelRodControl';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxMelRodControl';
params.modulationDirection = 'MelanopsinDirectedRodControl';
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% L-M
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxMelRodControl';
params.modulationDirection = 'LMinusMDirectedRodControl';
params.modulationContrast = [0.09 -0.09];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMinusM, olCacheLMinusM, paramsLMinusM] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);

paramsLMinusM.modulationDirection = 'LMinusMDirectedRodControl';
paramsLMinusM.cacheFile = ['Cache-' paramsLMinusM.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataLMinusM, olCacheLMinusM, paramsLMinusM);

clearvars;
theCalType = 'BoxBRandomizedLongCableDStubby1_ND02_ND40CassetteB';

%% Standard parameters
params.experiment = 'MelanopsinMRRodControlND40';
params.experimentSuffix = 'MelanopsinMRRodControlND40';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin,Rods';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution
%% MaxMel
params.pegBackground = false;
params.modulationDirection = {'MelanopsinDirectedRodControlND40'};
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[5]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% Mel shifted background
params.backgroundType = 'BackgroundMaxMelRodControl';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxMelRodControl';
params.modulationDirection = 'MelanopsinDirectedRodControlND40';
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
paramsMaxMel.cacheFile = ['Cache-' params.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% L-M
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxMelRodControl';
params.modulationDirection = 'LMinusMDirectedRodControlND40';
params.modulationContrast = [0.09 -0.09];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMinusM, olCacheLMinusM, paramsLMinusM] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);

paramsLMinusM.cacheFile = ['Cache-' paramsLMinusM.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataLMinusM, olCacheLMinusM, paramsLMinusM);