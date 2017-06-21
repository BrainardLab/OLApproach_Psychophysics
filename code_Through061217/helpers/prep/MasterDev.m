%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'MelLightLevelDependence';
theCalType = 'BoxALongCableCEyePiece2';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make background - half on
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = params.backgroundType;
params.calibrationType = theCalType;
params.maxPowerDiff = 10^(-1.5);
params.primaryHeadRoom = 0.02;
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make optimal background
params.pegBackground = false;
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = {'MelanopsinDirected' 'LMSDirected'};
params.modulationContrast = [];
params.whichReceptorsToIsolate = {[4] [1 2 3]};
params.whichReceptorsToIgnore = {[5 6 7 8] [5 6 7 8]};
params.whichReceptorsToMinimize = {[] []};
params.directionsYoked = [0 1];
params.directionsYokedAbs = [0 0];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedPenumbralIgnore - not silencing penumbral cones
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'MelanopsinDirectedPenumbralIgnore';
params.modulationContrast = [0.7];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedPenumbralIgnore - not silencing penumbral cones
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.7 0.7 0.7];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'SDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.10 -0.10];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.61 0.61 0.61];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.modulationDirection = 'LDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [1];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.modulationDirection = 'MDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.modulationDirection = 'RodDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [5];
params.whichReceptorsToIgnore = [6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%
% constraints
backgroundPrimary - isolatingPrimary{2} + backgroundPrimary = 2*backgroundPrimary + isolatingPrimary % neg
backgroundPrimary + isolatingPrimary{2}-backgroundPrimary = isolatingPrimary % pos

[backgroundPrimary isolatingPrimary{1}]*[2 -1]'
[backgroundPrimary isolatingPrimary{2}]*[0 1]'

bgPrimary*[1 0]