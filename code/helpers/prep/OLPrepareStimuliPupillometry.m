%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTF4Dxc';
theCalType = 'BoxBLongCableBEyePiece2';
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

%%% MAIN MODULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Isochromatic
params.modulationDirection = 'Isochromatic';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMMelDirected
params.modulationDirection = 'LMMelDirected';
params.modulationContrast = [0.45 0.45 0.45];
params.whichReceptorsToIsolate = [1 2 4];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirectedLegacy';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.20];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% Additional PT modulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMDirected
params.modulationDirection = 'LMPenumbraDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% LMDirected
params.modulationDirection = 'LMDirected';
params.modulationContrast = [0.45 0.45];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);



