%% Note, background luminance should be ~3,700 cd/m2

%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerLMS';
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

%% Generate the modulations
% LMDirected
params.modulationDirection = 'LMDirected';
params.modulationContrast = [0.45 0.45];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

% LMinusMDirected
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.12 -0.12];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% Validations
theDirections = {'LMSDirected'};

basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
zeroVector = zeros(1, length(theDirections));
theOnVector = zeroVector;
theOnVector(1) = 1;
theOffVector = zeroVector;
theOffVector(end) = 1;
WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(basePath, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', false);
    close all;
end

% Save out the validation directories
dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
for d = 1:length(validationPath)
    fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
    fprintf(fid, '%s\n', validationPath{d});
end

%% Make the modulations
theDirections = {'sLMSDirected'};
theAges = [27 29 45]; % MM = 29, GA = 45, MS = 27

for o = theAges;
    for d = [1]
        fprintf('Age: %g\n', o);
        OLReceptorIsolateMakeModulationStartsStops(['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation.cfg'], o);
    end
end

%% Check all validations
theCalDate = '30-Apr-2015_21_26_52'; % Enter something here

for d = 1:length(theDirections)
    OLReceptorIsolateCheckAllValidations(basePath, theDirections{d}, theCalType, theCalDate);
end
