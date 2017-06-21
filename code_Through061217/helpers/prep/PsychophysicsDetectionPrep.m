theCalType = 'BoxCShortCableAEyePiece3BeamsplitterOn';

%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'PsychophysicsDetection';
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
params.backgroundType = 'BackgroundHalfOn';

%% Make background
params.modulationDirection = params.backgroundType;
params.calibrationType = theCalType;
params.maxPowerDiff = 10^(-1.5);
params.primaryHeadRoom = 0.02;
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LMSDirected
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.40 0.40 0.40];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirectedLegacy';
params.modulationContrast = [0.40];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MelanopsinDirectedLegacy - silencing penumbral cones
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.18];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LMinusMDirected
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.12 -0.12];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.40];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %% Validate these modulations
%%
theDirections = {'LMSDirected', 'MelanopsinDirectedLegacy', 'MelanopsinDirected' 'SDirected', 'LMinusMDirected'};
theCalType = 'BoxCShortCableAEyePiece3BeamsplitterOn';
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

%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Make pupil modulations for an observer
% nullingID = 'MelBright_C008'; o = 29;
% OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-60s.cfg', o, nullingID);
% OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-45sWindowedFrequencyModulation.cfg', o, nullingID)
% OLReceptorIsolateMakeModulationStartsStops('Modulation-LMSDirected-45sWindowedFrequencyModulation.cfg', o, nullingID)