%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerNulling';
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMSDirected
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.2 0.2 0.2];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMinusMDirected
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.12 -0.12];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LightFlux
params.modulationDirection = 'LightFlux';
params.modulationContrast = [0.9];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validation
theDirections = {'LMSDirected', 'MelanopsinDirected', 'LMinusMDirected', 'SDirected', 'LightFlux'};

cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
zeroVector = zeros(1, length(theDirections));
theOnVector = zeroVector;
theOnVector(1) = 1;
theOffVector = zeroVector;
theOffVector(end) = 1;
WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', false);
    close all;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Nulling
theCalType = 'OLBoxALongCableBEyePiece2';
nullingID = 'M071715S'; o = 28;
nullExpt(nullingID, o, theCalType); % MS

%% Nulling
theCalType = 'OLBoxALongCableBEyePiece2';
nullingID = 'M071715M'; o = 29;
nullExpt(nullingID, o, theCalType); % MM

%% Nulling
theCalType = 'OLBoxALongCableBEyePiece2';
nullingID = 'G071715A'; o = 45;
nullExpt(nullingID, o, theCalType); % HA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modulations
% Make the modulations
nullingID = 'M071715M'; o = 29;
theCalType = 'BoxALongCableBEyePiece2';
OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Background
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedUnnulled-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID); % Not nulled
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedNulled-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Nulled
OLReceptorIsolateMakeModulationStartsStops('Modulation-NulledResidualSplatter-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Residual
OLReceptorIsolateMakeModulationStartsStops('Modulation-LightFlux-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Residual

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validate nulling
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
nullingID = 'G071715A';
OLMeasureNullingSpd(fullfile(basePath, [nullingID '_nulling.mat']));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make FSL covariates

protocol = 'TTFMRFlickerNulled';
MakeCovariatesFSL(basePath, 'M071715M', protocol);
MakeCovariatesFSL(basePath, 'M071715S', protocol);
MakeCovariatesFSL(basePath, 'G071715A', protocol);
%
protocol = 'TTFMRFlickerLightFluxControl';
MakeCovariatesFSL(basePath, 'M071715M', protocol);
MakeCovariatesFSL(basePath, 'M071715S', protocol);
MakeCovariatesFSL(basePath, 'G071715A', protocol);


%
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/';
protocol = 'MRLightFlux';
MakeCovariatesFSL(basePath, 'G08042015A', protocol);