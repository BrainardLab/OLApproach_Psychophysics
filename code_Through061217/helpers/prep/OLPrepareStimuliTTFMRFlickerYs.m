%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerYs';
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
% %% LMDirected
% params.modulationDirection = 'LMDirected';
% params.modulationContrast = [0.45 0.45];
% params.whichReceptorsToIsolate = [1 2];
% params.whichReceptorsToIgnore = [5 6 7];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% SDirected
% params.modulationDirection = 'SDirected';
% params.modulationContrast = [0.45];
% params.whichReceptorsToIsolate = [3];
% params.whichReceptorsToIgnore = [5 8];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% MelanopsinDirected
% params.modulationDirection = 'MelanopsinDirected';
% params.modulationContrast = [0.17];
% params.whichReceptorsToIsolate = [4];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% LMinusMDirected
% params.modulationDirection = 'LMinusMDirected';
% params.modulationContrast = [0.10 -0.10];
% params.whichReceptorsToIsolate = [1 2];
% params.whichReceptorsToIgnore = [5 6 7];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%% VALIDATIONS
%% Validate these modulations
SPOT_CHECK = true;
theDirections = {'LMDirected', 'SDirected', 'MelanopsinDirected', 'LMinusMDirected'};

cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theOnVector = [1 0 0 0 0];
theOffVector = [0 0 0 0 1];
WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', SPOT_CHECK, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', ~SPOT_CHECK);
    close all;
end

% Save out the validation directories
dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
for d = 1:length(validationPath)
    fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
    fprintf(fid, '%s\n', validationPath{d});
end

%%% MAKE MODULATIONS
%% Make the modulations
theDirections = {'sLMinusMDirected', 'sLMDirected', 'sSDirected', 'sMelanopsinDirected'};
theAges = [25 28 26 44];

for o = theAges;
    for d = 5:6
        fprintf('Age: %g\n', o);
        OLReceptorIsolateMakeModulationStartsStops(['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation.cfg'], o);
    end
end

%% Check all validations
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theDirections = {'LMinusMDirected', 'LMDirected', 'SDirected', 'MelanopsinDirected'};
theCalType = 'BoxBLongCableBEyePiece2';
theCalDate = '16-Apr-2014_18_05_52';

for d = 1:length(theDirections)
    OLReceptorIsolateCheckAllValidations(basePath, theDirections{d}, theCalType, theCalDate);
end