%% =========================== CALIBRATION ===========================
%ol = OneLight;
%OLCalibrate;

%% =========================== CACHE FILES ===========================
%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlicker';
theCalType = 'BoxALongCableBEyePiece2';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.1;
params.backgroundType = 'BackgroundHalfOn';

%% Make background
params.modulationDirection = params.backgroundType;
params.calibrationType = theCalType;
params.maxPowerDiff = 10^(-1.5);
params.primaryHeadRoom = 0.02;
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% LightFlux
params.modulationDirection = 'LightFlux';
params.modulationContrast = [0.9]; % Contrast
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% ========================= MAKE MODULATIONS =========================
observerAgeInYrs = 32;
OLReceptorIsolateMakeModulationStartsStops('Modulation-LightFlux-12sWindowedFrequencyModulation.cfg', observerAgeInYrs, theCalType, []) % Light flux