%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'MRControl4HzMelanopsin';
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
[cacheData, olCache, params] = OLReceptorIsolateMakeBackgroundNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMSDirected
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.2 0.2 0.2];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMinusMDirected
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.12 -0.12];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMinusMDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validation
theDirections = {'LMSDirected', 'MelanopsinDirected', 'LMinusMDirected'};

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

%% Nulling
theCalType = 'OLBoxALongCableBEyePiece2';
nullExpt('psq001', 28, theCalType); % psq001 - MS

%%
theCalType = 'OLBoxALongCableBEyePiece2';
nullExpt('psq002', 26, theCalType); % psq002 - SS

%%
theCalType = 'OLBoxALongCableBEyePiece2';
nullExpt('psq003', 45, theCalType); % psq003 - GA

%%
theCalType = 'OLBoxALongCableBEyePiece2';
nullExpt('psq004', 20, theCalType); % psq004 - AR1

%% 
theCalType = 'OLBoxALongCableBEyePiece2';
nullExpt('psq005', 38, theCalType); % psq005 - AR2

%% Pupil experiments
% Make the modulations
nullingID = 'psq005'; o = 38;
theCalType = 'BoxALongCableBEyePiece2';
OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-60s.cfg', o, theCalType, nullingID);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedNulled-24sSqWave.cfg', o, theCalType, nullingID)
OLReceptorIsolateMakeModulationStartsStops('Modulation-LMSDirectedNulled-24sSqWave.cfg', o, theCalType, nullingID)

%% fMRI experiments
% Make the modulations
OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Background
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedUnnulled-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID); % Not nulled
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedNulled-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Nulled
OLReceptorIsolateMakeModulationStartsStops('Modulation-NulledResidualSplatter-12sWindowedFrequencyModulation.cfg', o, theCalType, nullingID) % Residual
