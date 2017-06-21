%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'EMGLuxotonic';
theCalType = 'BoxAShortCableBEyePiece2_ND06';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;
params.backgroundType = 'BackgroundHalfOn';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LMSDirected
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.40 0.40 0.40];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirectedLegacy';
params.modulationContrast = [0.40];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.15];
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
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.40];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % NOISE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% L-directed scaled for noise
% params.modulationDirection = 'LDirectedNoise';
% params.modulationContrast = [0.05];
% params.whichReceptorsToIsolate = [1];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% M-directed scaled for noise
% params.modulationDirection = 'MDirectedNoise';
% params.modulationContrast = [0.05];
% params.whichReceptorsToIsolate = [2];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% S-directed scaled for noise
% params.modulationDirection = 'SDirectedNoise';
% params.modulationContrast = [0.05];
% params.whichReceptorsToIsolate = [3];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %% Validate these modulations
% theDirections = {'LMSDirected', 'MelanopsinDirectedLegacy', 'SDirected', 'LMinusMDirected'};
% 
% cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
% zeroVector = zeros(1, length(theDirections));
% theOnVector = zeroVector;
% theOnVector(1) = 1;
% theOffVector = zeroVector;
% theOffVector(end) = 1;
% WaitSecs(2);
% for d = 1:length(theDirections)
%     [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
%         theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', false);
%     close all;
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Make pupil modulations for an observer
% nullingID = 'MelBright_C008'; o = 29;
% OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-60s.cfg', o, nullingID);
% OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-45sWindowedFrequencyModulation.cfg', o, nullingID)
% OLReceptorIsolateMakeModulationStartsStops('Modulation-LMSDirected-45sWindowedFrequencyModulation.cfg', o, nullingID)