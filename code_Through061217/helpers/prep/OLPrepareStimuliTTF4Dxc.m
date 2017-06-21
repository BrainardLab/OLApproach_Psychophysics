%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTF4Dxc';
theCalType = 'BoxBLongCableBEyePiece2_03ND';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = true;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;

%%% MAIN MODULATIONS
%% LMDirected
params.modulationDirection = 'LMDirected';
params.modulationContrast = [0.5 0.5];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% SDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.5];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% MelanopsinDirectedLegacy - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirectedLegacy';
params.modulationContrast = [0.5];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% MelanopsinDirected
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% PenumbralLMDirectedMelIgnore
params.modulationDirection = 'PenumbralLMDirectedMelIgnore';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [4 5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% MelanopsinDirectedLegacyScreeningUncorrected - not silencing penumbral cones
params.modulationDirection = 'MelanopsinDirectedLegacyScreeningUncorrected';
params.modulationContrast = [0.5];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% MelanopsinDirectedScreeningUncorrected
params.modulationDirection = 'MelanopsinDirectedScreeningUncorrected';
params.modulationContrast = [0.2];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%% VALIDATIONS
%% Validate these modulations
SPOT_CHECK = false;
theDirections = {'LMDirected', 'SDirected', 'MelanopsinDirected', 'MelanopsinDirectedLegacy', 'PenumbralLMDirectedMelIgnore'};

cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theOnVector = [1 0 0 0 0];
theOffVector = [0 0 0 0 1];
WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', SPOT_CHECK, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', false);
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
theDirections = {'LMDirected', 'MelanopsinDirected', 'MelanopsinDirectedLegacy'};
theAges = [44];

for o = theAges;
    fprintf('Age: %g\n', o);
    % L+M CRF
    OLReceptorIsolateMakeModulationStartsStops(['Modulation-LMDirected-45sWindowedFrequencyCRFModulation.cfg'], o);
    
    % Melanopsin 20%
    OLReceptorIsolateMakeModulationStartsStops(['Modulation-MelanopsinDirected-45sWindowedFrequencyModulation.cfg'], o);
    
    % MelanopsinLegacy 20% (40% of 50%)
    OLReceptorIsolateMakeModulationStartsStops(['Modulation-MelanopsinDirectedLegacy-45sWindowedFrequencyScaledContrastModulation.cfg'], o);
end


%% Make background
for o = theAges;
    OLReceptorIsolateMakeModulationStartsStops(['Modulation-Background-300s.cfg'], o);
end
% 
% %% Make a KleinSilent modulation
% %% Standard parameters
% params.experiment = 'OLFlickerSensitivity';
% params.experimentSuffix = 'TTF4Dxc';
% theCalType = 'BoxBLongCableBEyePiece2_03ND';
% params.calibrationType = theCalType;
% params.whichReceptorsToMinimize = [];
% params.CALCULATE_SPLATTER = false;
% params.maxPowerDiff = 10^(-1.5);
% params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
% params.fieldSizeDegrees = 27.5;
% params.isActive = 1;
% params.useAmbient = 1;
% params.REFERENCE_OBSERVER_AGE = 32;
% params.primaryHeadRoom = 0.02;
% params.checkKlein = true;
% 
% % Isochromatic
% params.modulationDirection = 'KleinSilent';
% params.modulationContrast = [];
% params.whichReceptorsToIsolate = [1 2 3 4 5 6 7 8];
% params.whichReceptorsToIgnore = [];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %%% MAIN MODULATIONS
% %% Isochromatic
% params.experiment = 'OLFlickerSensitivity';
% params.experimentSuffix = 'TTFMRFlickerZ';
% theCalType = 'BoxBLongCableBEyePiece2_03ND';
% params.calibrationType = theCalType;
% params.whichReceptorsToMinimize = [];
% params.CALCULATE_SPLATTER = false;
% params.maxPowerDiff = 10^(-1.5);
% params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
% params.fieldSizeDegrees = 27.5;
% params.isActive = 1;
% params.useAmbient = 1;
% params.REFERENCE_OBSERVER_AGE = 32;
% params.primaryHeadRoom = 0.02;
% params.checkKlein = true;
% 
% % Make the modulation
% params.modulationDirection = 'Isochromatic';
% params.modulationContrast = [0.45 0.45 0.45 0.45];
% params.whichReceptorsToIsolate = [1 2 3 4];
% params.whichReceptorsToIgnore = [5 6 7];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% 
% %% Check all validations
% basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
% theDirections = {'LMinusMDirected', 'LMDirected', 'SDirected', 'MelanopsinDirected', 'LMPenumbraDirected'};
% theCalType = 'BoxBLongCableBEyePiece2';
% theCalDate = '16-Apr-2014_18_05_52';
% 
% for d = 1:length(theDirections)
%     OLReceptorIsolateCheckAllValidations(basePath, theDirections{d}, theCalType, theCalDate);
% end
% 
% %% Check all validations (LOW LIGHT LEVEL)
% basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
% theDirections = {'LMinusMDirected', 'LMDirected', 'SDirected', 'Isochromatic'};
% theCalType = 'BoxALongCableBEyePiece1';
% theCalDate = '15-Mar-2014_15_34_15';
% 
% for d = 1:length(theDirections)
%     OLReceptorIsolateCheckAllValidations(basePath, theDirections{d}, theCalType, theCalDate);
% end