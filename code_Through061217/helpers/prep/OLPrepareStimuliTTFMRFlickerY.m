theEccentricities = 1:120;

%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerY';
theCalType = 'BoxALongCableBEyePiece2';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,LCone1Deg,MCone1Deg,SCone1Deg';
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;

%%%
params.fieldSizeDegrees = 10;
%%%

params.backgroundType = 'BackgroundHalfOn';

%% SDirected
close all
params.modulationDirection = 'SDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [4 5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);

for e = 1:length(theEccentricities)
    T_receptors = GetHumanPhotoreceptorSS([380 2 201], {'LCone', 'MCone', 'SCone', 'Melanopsin'}, theEccentricities(e), 32, 4.7, ...
        [], cacheData.data(32).describe.fractionBleached(1:4), [], []);
    contrast(:, e) = (T_receptors*cacheData.data(32).differenceSpd) ./ (T_receptors*cacheData.data(32).backgroundSpd);
end

colors = [0 1 0 ; 1 0 0 ; 0 0 1 ; 0.3 0.9 0.5];
for i = 1:3
   plot(theEccentricities/2, 100*contrast(i, :), 'Color', colors(i, :)); hold on;
end
xlabel('Unilateral eccentricity [°]');
ylabel('Contrast [%)');
title([num2str(params.fieldSizeDegrees) '° field size, S cone isolation']);
pbaspect([1 1 1]); box off;

set(gcf, 'PaperPosition', [0 0 4 4]);
set(gcf, 'PaperSize', [4 4]);
saveas(gcf, ['SCone_' num2str(params.fieldSizeDegrees) 'Deg.pdf'], 'pdf');
close(gcf)

%% L-M
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.20 -0.20];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [4 5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);

for e = 1:length(theEccentricities)
    T_receptors = GetHumanPhotoreceptorSS([380 2 201], {'LCone', 'MCone', 'SCone', 'Melanopsin'}, theEccentricities(e), 32, 4.7, ...
        [], cacheData.data(32).describe.fractionBleached(1:4), [], []);
    contrast(:, e) = (T_receptors*cacheData.data(32).differenceSpd) ./ (T_receptors*cacheData.data(32).backgroundSpd);
end

colors = [0 1 0 ; 1 0 0 ; 0 0 1 ; 0.3 0.9 0.5];
for i = 1:3
   plot(theEccentricities/2, 100*contrast(i, :), 'Color', colors(i, :)); hold on;
end
xlabel('Unilateral eccentricity [°]');
ylabel('Contrast [%)');
title([num2str(params.fieldSizeDegrees) '° field size, L-M cone isolation']);
pbaspect([1 1 1]); box off;

set(gcf, 'PaperPosition', [0 0 4 4]);
set(gcf, 'PaperSize', [4 4]);
saveas(gcf, ['LMinusM_' num2str(params.fieldSizeDegrees) 'Deg.pdf'], 'pdf');



%% MelanopsinDirected
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.17];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% LMinusMDirected
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.10 -0.10];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%% PURKINJE TREE MODULATIONS
%% LMUmbraDirected
params.modulationDirection = 'LMPenumbraDirected';
params.modulationContrast = [0.018 0.018];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%% MAIN MODULATIONS
%% LMDirected
params.modulationDirection = 'MelanopsinRodDirected';
params.modulationContrast = [0.06 0.06];
params.whichReceptorsToIsolate = [4 5];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%% VALIDATIONS
%% Validate these modulations
SPOT_CHECK = true;
theDirections = {'LMDirected', 'SDirected', 'MelanopsinDirected', 'LMinusMDirected', 'KleinSilent', 'LMPenumbraDirected'};

cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theOnVector = [1 0 0 0 0 0];
theOffVector = [0 0 0 0 0 1];
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
theDirections = {'LMinusMDirected', 'LMDirected', 'SDirected', 'MelanopsinDirected', 'LMPenumbraDirected', 'LMDirectedScaled'};
theAges = [25 28 26 44];

for o = theAges;
    for d = 1:length(theDirections)
        fprintf('Age: %g\n', o);
        OLReceptorIsolateMakeModulationStartsStops(['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation.cfg'], o);
    end
end

%% Make a KleinSilent modulation
%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerZ';
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
params.checkKlein = true;

% Isochromatic
params.modulationDirection = 'KleinSilent';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [1 2 3 4 5 6 7 8];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%% MAIN MODULATIONS
%% Isochromatic
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerZ';
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
params.checkKlein = true;

% Make the modulation
params.modulationDirection = 'Isochromatic';
params.modulationContrast = [0.45 0.45 0.45 0.45];
params.whichReceptorsToIsolate = [1 2 3 4];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% Check all validations
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theDirections = {'LMinusMDirected', 'LMDirected', 'SDirected', 'MelanopsinDirected', 'LMPenumbraDirected'};
theCalType = 'BoxBLongCableBEyePiece2';
theCalDate = '16-Apr-2014_18_05_52';

for d = 1:length(theDirections)
    OLReceptorIsolateCheckAllValidations(basePath, theDirections{d}, theCalType, theCalDate);
end

%% Check all validations (LOW LIGHT LEVEL)
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theDirections = {'LMinusMDirected', 'LMDirected', 'SDirected', 'Isochromatic'};
theCalType = 'BoxALongCableBEyePiece1';
theCalDate = '15-Mar-2014_15_34_15';

for d = 1:length(theDirections)
   OLReceptorIsolateCheckAllValidations(basePath, theDirections{d}, theCalType, theCalDate);
end