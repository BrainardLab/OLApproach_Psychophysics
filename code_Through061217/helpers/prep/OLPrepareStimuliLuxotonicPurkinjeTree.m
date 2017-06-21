%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'EMGLuxotonic';
theCalType = 'BoxALongCableCEyePiece2';
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
%% 
% %%% MAIN MODULATIONS
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Isochromatic
params.modulationDirection = 'Isochromatic';
params.modulationContrast = [0.40];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Background
params.modulationDirection = 'Background';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOISE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% L-directed scaled for noise
params.modulationDirection = 'LDirectedNoise';
params.modulationContrast = [0.05];
params.whichReceptorsToIsolate = [1];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% M-directed scaled for noise
params.modulationDirection = 'MDirectedNoise';
params.modulationContrast = [0.05];
params.whichReceptorsToIsolate = [2];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% S-directed scaled for noise
params.modulationDirection = 'SDirectedNoise';
params.modulationContrast = [0.05];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelMinusS
params.modulationDirection = 'MelMinusS';
params.modulationContrast = [-0.20 0.40];
params.whichReceptorsToIsolate = [3 4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelPlusS
params.modulationDirection = 'MelPlusS';
params.modulationContrast = [0.20 0.40];
params.whichReceptorsToIsolate = [3 4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);



%% Penumbral cone
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.modulationDirection = 'LMPenumbraDirected200um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [9 10];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% Penumbral cone
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo5um,MConeHemo5um,SConeHemo5um';
params.modulationDirection = 'LMPenumbraDirected5um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo10um,MConeHemo10um,SConeHemo10um,LConeHemo100um,MConeHemo100um,SConeHemo100um';
params.modulationDirection = 'LMPenumbraDirected10umE';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo10um,MConeHemo10um,SConeHemo10um';
params.modulationDirection = 'LMPenumbraDirected10um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo25um,MConeHemo25um,SConeHemo25um';
params.modulationDirection = 'LMPenumbraDirected25um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo50um,MConeHemo50um,SConeHemo50um';
params.modulationDirection = 'LMPenumbraDirected50um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo100um,MConeHemo100um,SConeHemo100um';
params.modulationDirection = 'LMPenumbraDirected100um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo200um,MConeHemo200um,SConeHemo200um';
params.modulationDirection = 'LMPenumbraDirected200um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemoLegacy,MConeHemoLegacy,SConeHemoLegacy';
params.modulationDirection = 'LMPenumbraDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo10um,MConeHemo10um,SConeHemo10um,LConeHemo200um,MConeHemo200um,SConeHemo200um';
params.modulationDirection = 'LMPenumbraDirected10um';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [9 10 11];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


% % 
% % %% MelanopsinDirectedLegacy - not silencing penumbral cones
% % params.modulationDirection = 'MelanopsinDirected';
% % params.modulationContrast = [0.20];
% % params.whichReceptorsToIsolate = [4];
% % params.whichReceptorsToIgnore = [5];
% % params.receptorIsolateMode = 'Standard';
% % params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% % [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% % OLReceptorIsolateSaveCache(cacheData, olCache, params);
% % 
% % 
% % %% Additional PT modulations
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %% LMDirected
% params.modulationDirection = 'LMPenumbraDirected';
% params.modulationContrast = [];
% params.whichReceptorsToIsolate = [6 7];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% % % 
% % %% LMDirected
% % params.modulationDirection = 'LMDirected';
% % params.modulationContrast = [0.45 0.45];
% % params.whichReceptorsToIsolate = [1 2];
% % params.whichReceptorsToIgnore = [5 6 7];
% % params.receptorIsolateMode = 'Standard';
% % params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% % [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% % OLReceptorIsolateSaveCache(cacheData, olCache, params);
% % 
% % %% LMPenumbraDirectedMelIgnore
% % params.modulationDirection = 'LMPenumbraDirectedMelIgnore';
% % params.modulationContrast = [];
% % params.whichReceptorsToIsolate = [6 7];
% % params.whichReceptorsToIgnore = [4 5];
% % params.receptorIsolateMode = 'Standard';
% % params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% % [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% % OLReceptorIsolateSaveCache(cacheData, olCache, params);
% % 
% % 
% % %% More modulations
% % params.modulationDirection = 'LMDirectedAllConesInPhase';
% % params.modulationContrast = [0.3 0.3 0.3 0.3];
% % params.whichReceptorsToIsolate = [1 2 6 7];
% % params.whichReceptorsToIgnore = [5];
% % params.receptorIsolateMode = 'Standard';
% % params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% % [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% % OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemoLegacy,MConeHemoLegacy,SConeHemoLegacy';
%% LMDirected
params.modulationDirection = 'LMPenumbraDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% LMDirected
params.modulationDirection = 'LMOpenFieldDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
% % 
% % 
%% More modulations

params.modulationDirection = 'SPenumbraDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [8];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% More modulations
params.modulationDirection = 'SOpenFieldDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% More modulations
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% LMDirected
% params.modulationDirection = 'LMinusMOpenFieldDirected';
% params.modulationContrast = [0.05 -0.05];
% params.whichReceptorsToIsolate = [1 2];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% 
% % %% LMDirected
% params.modulationDirection = 'LMinusMPenumbraDirected';
% params.modulationContrast = [0.015 -0.015];
% params.whichReceptorsToIsolate = [6 7];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% % 
% 
% %% LMDirected
% params.modulationDirection = 'LPenumbraDirected';
% params.modulationContrast = [];
% params.whichReceptorsToIsolate = [6];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% 
% %% LMDirected
% params.modulationDirection = 'MPenumbraDirected';
% params.modulationContrast = [];
% params.whichReceptorsToIsolate = [7];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% LMinusMDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
%%
% % %% Validate these modulations
theDirections = {'Isochromatic', 'LMSDirected', 'MelanopsinDirectedLegacy'};

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

% Save out the validation directories
dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
for d = 1:length(validationPath)
    fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
    fprintf(fid, '%s\n', validationPath{d});
end
% % 
% % ol = OneLight;
% % ol.shutdown;