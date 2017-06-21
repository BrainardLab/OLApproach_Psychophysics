%OLCalibrate;

%% Set up parmaeters
observerAge = [25 26 44];

theCalType = 'BoxBLongCableBEyePiece1';
theDirections = {'LMDirected', 'LMinusMDirected', 'SDirected', 'MelanopsinDirected', 'RodDirected', 'MelanopsinDirectedRobust', 'OmniSilent', 'Isochromatic'};

whichReceptorsToIsolate = {[1 2] ; [1 2] ; [3] ; [4] ; [5] ; [4] ; [] ; [1 2 3 4]};
whichReceptorsToIgnore = {[5 7 8:13] ; [5 7 8:13] ; [5 6 8:13] ; [5 6 7 8:13] ; [7 8:13] ; [7 8:13] ; [] ; []};
modulationContrast = {[0.5 0.5], [0.1 -0.1], [0.4], [0.5], [0.05], [0.09], [], [0.5 0.5 0.5 0.5]};
receptorIsolateMode = {'Standard' ; 'Standard' ; 'Standard' ; 'Standard' ; 'Standard' ; 'Standard' ; 'EnforceSpectralChange' ; 'Standard'};

params.experiment = 'OLFlickerSensitivity';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = true;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,SConeR-2,MConeR-2,LConeR-2,MelR-2,SConeR+2,MConeR+2,LConeR+2,MelR+2';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;

% Iterate over the directions
for d = 1:length(theDirections)
    params.modulationDirection = theDirections{d};
    params.modulationContrast = modulationContrast{d};
    params.whichReceptorsToIsolate = whichReceptorsToIsolate{d};
    params.whichReceptorsToIgnore = whichReceptorsToIgnore{d};
    params.receptorIsolateMode = receptorIsolateMode{d};
    params.cacheFile = ['Cache-' theDirections{d} '.mat'];
    [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
end

%% Blood-screened modulations modulations
theCalType = 'BoxBLongCableBEyePiece1';
theDirections = {'SConeHemoDirected', 'MelanopsinHemoRobust', 'RodRobustHemo', 'MelanopsinConeHemoRobust', 'LConeHemoDirected', 'MConeHemoDirected', 'LMConeHemoDirected', 'MelanopsinAllSilent'};
whichReceptorsToIsolate = {[8], [4], [5], [4], [6], [7], [6 7], [4]};
whichReceptorsToIgnore = {[], [], [], [5], [5], [5], [5], [5]};
modulationContrast = {[], [], [], [], [], [], [], [], []};
receptorIsolateMode = {'Standard', 'Standard', 'Standard', 'Standard', 'Standard', 'Standard', 'Standard', 'Standard', 'Standard', 'Standard'};

params.experiment = 'OLFlickerSensitivity';
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

for d = [7 8]
    params.modulationDirection = theDirections{d};
    params.modulationContrast = modulationContrast{d};
    params.whichReceptorsToIsolate = whichReceptorsToIsolate{d};
    params.whichReceptorsToIgnore = whichReceptorsToIgnore{d};
    params.receptorIsolateMode = receptorIsolateMode{d};
    params.cacheFile = ['Cache-' theDirections{d} '.mat'];
    [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
end

%% Klein
% params = OLReceptorIsolatePrepareConfig('Cache-KleinSilent-OLLongCableAEyePiece1.cfg');
% params.calibrationType = theCalType;
% params.whichReceptorsToMinimize = [];
% params.CALCULATE_SPLATTER = true;
% params.maxPowerDiff = 10^(-1.5);
% params.fieldSizeDegrees = 27.5;
% params.isActive = 1;
% params.useAmbient = 1;
% params.REFERENCE_OBSERVER_AGE = 32;
% params.primaryHeadRoom = 0.02;
% [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% Validate this
theCalType = 'BoxBLongCableBEyePiece1';
theDirections = {'LMDirected', 'LMinusMDirected', 'SDirected', 'MelanopsinDirected', 'RodDirected', 'MelanopsinDirectedRobust', 'OmniSilent', 'Isochromatic'};

cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theOnVector = [1 0 0 1 0 0 0 0];
theOffVector = [0 0 0 0 0 0 0 1];
WaitSecs(2);
for d = [4 5 6 7]
    OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', false);
    close all;
end

%% Make the modulations
theDirections = {'LMDirected', 'LMinusMDirected', 'SDirected', 'MelanopsinDirected', 'RodDirected', 'MelanopsinDirectedRobust', 'MelanopsinDirectedEquivContrastRobust', 'OmniSilent', 'Isochromatic', 'Background'};

for o = [26]%2544]
    for d = [5 6 7 8]
        fprintf('Age: %g\n', o);
        OLReceptorIsolateMakeModulationStartsStops(['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation.cfg'], o);
    end
end