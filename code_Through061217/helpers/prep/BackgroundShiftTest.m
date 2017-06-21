%% General procedure
theCalibrationTypes = {'BoxDLongCableCEyePiece2'};

for c = 1:length(theCalibrationTypes)
    %% Standard parameters
    params.experiment = 'OLFlickerSensitivity';
    params.experimentSuffix = 'NullingPopulationData';
    params.calibrationType = theCalibrationTypes{c};
    params.whichReceptorsToMinimize = [];
    params.CALCULATE_SPLATTER = false;
    params.maxPowerDiff = 10^(-1.5);
    params.photoreceptorClasses = 'LCone10DegTabulatedSS,MCone10DegTabulatedSS,SCone10DegTabulatedSS,LCone2DegTabulatedSS,MCone2DegTabulatedSS,SCone2DegTabulatedSS,Melanopsin';
    params.fieldSizeDegrees = 27.5;
    params.pupilDiameterMm = 6;
    params.isActive = 1;
    params.useAmbient = 1;
    params.REFERENCE_OBSERVER_AGE = 32;
    params.primaryHeadRoom = 0.05;
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Make optimal background
    params.pegBackground = false;
    params.backgroundType = 'BackgroundOptim';
    params.modulationDirection = {'MelanopsinDirected'};
    params.modulationContrast = [];
    params.whichReceptorsToIsolate = {[7]};
    params.whichReceptorsToIgnore = {[]};
    params.whichReceptorsToMinimize = {[4 5 6] []};
    params.directionsYoked = [0];
    params.directionsYokedAbs = [0];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
    [cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MelanopsinDirectedPenumbralIgnore - not silencing penumbral cones
    params.backgroundType = 'BackgroundOptim';
    params.modulationDirection = 'MelanopsinDirectedPenumbralIgnore';
    params.modulationContrast = [];
    params.whichReceptorsToIsolate = [7];
    params.whichReceptorsToIgnore = [4 5 6];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    
end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% L+M+S-Directed
%     params.backgroundType = 'BackgroundOptim';
%     params.modulationDirection = 'LMSDirected';
%     params.modulationContrast = [0.58 0.58 0.58];
%     params.whichReceptorsToIsolate = [1 2 3];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.whichReceptorsToMinimize = [];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% L-M
%     params.backgroundType = 'BackgroundOptim';
%     params.modulationDirection = 'LMinusMDirected';
%     params.modulationContrast = [0.10 -0.10];
%     params.whichReceptorsToIsolate = [1 2];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.whichReceptorsToMinimize = [];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% S
%     params.backgroundType = 'BackgroundOptim';
%     params.modulationDirection = 'SConeDirected';
%     params.modulationContrast = [0.10];
%     params.whichReceptorsToIsolate = [3];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.whichReceptorsToMinimize = [];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % NOISE
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% L-directed scaled for noise
%     params.modulationDirection = 'LDirectedNoise';
%     params.modulationContrast = [0.05];
%     params.whichReceptorsToIsolate = [1];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     %% M-directed scaled for noise
%     params.modulationDirection = 'MDirectedNoise';
%     params.modulationContrast = [0.05];
%     params.whichReceptorsToIsolate = [2];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     %% S-directed scaled for noise
%     params.modulationDirection = 'SDirectedNoise';
%     params.modulationContrast = [0.05];
%     params.whichReceptorsToIsolate = [3];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     % LMS scaled for noise
%     params.modulationDirection = 'LMSDirectedNoise';
%     params.modulationContrast = [0.03 0.03 0.03];
%     params.whichReceptorsToIsolate = [1 2 3];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%     
%     %% LMS scaled for noise
%     params.modulationDirection = 'LMinusMDirectedNoise';
%     params.modulationContrast = [0.03 -0.03];
%     params.whichReceptorsToIsolate = [1 2];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Validation
% theDirections = {'MelanopsinDirectedPenumbralIgnore', 'LMSDirected', 'LMinusMDirected' 'SConeDirected'};
% theCalType = 'BoxAShortCableCEyePiece2_ND10';
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


