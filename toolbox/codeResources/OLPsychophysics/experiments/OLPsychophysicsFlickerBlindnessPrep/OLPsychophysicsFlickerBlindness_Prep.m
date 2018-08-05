%% General procedure
theCalibrationTypes = {'BoxARandomizedLongCableBEyePiece1_ND10'};

for c = 1:length(theCalibrationTypes)
    %% Standard parameters
    params.experiment = 'OLPsychophysics';
    params.experimentSuffix = 'FlickerBlindness';
    params.calibrationType = theCalibrationTypes{c};
    params.whichReceptorsToMinimize = [];
    params.CALCULATE_SPLATTER = false;
    params.maxPowerDiff = 10^(-2);
    params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
    params.fieldSizeDegrees = 27.5;
    params.pupilDiameterMm = 8;
    params.isActive = 1;
    params.useAmbient = 1;
    params.REFERENCE_OBSERVER_AGE = 32;
    params.primaryHeadRoom = 0.05;
    %
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% Make optimal background
%     params.pegBackground = false;
%     params.backgroundType = 'BackgroundHalfOn';
%     params.modulationDirection = {'MelanopsinDirected' 'LMSDirected'};
%     params.modulationContrast = [];
%     params.whichReceptorsToIsolate = {[4] [1 2 3]};
%     params.whichReceptorsToIgnore = {[5 6 7 8] [5 6 7 8]};
%     params.whichReceptorsToMinimize = {[] []};
%     params.directionsYoked = [0 1];
%     params.directionsYokedAbs = [0 0];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MelanopsinDirectedPenumbralIgnore - not silencing penumbral cones
    params.backgroundType = 'BackgroundHalfOn';
    params.modulationDirection = 'LightFluxHalfOn';
    params.modulationContrast = [0.8 0.8 0.8];
    params.whichReceptorsToIsolate = [1 2 3];
    params.whichReceptorsToIgnore = [5 6 7 8];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MelanopsinDirectedPenumbralIgnore - not silencing penumbral cones
    params.backgroundType = 'BackgroundHalfOn';
    params.modulationDirection = 'LightFluxStepHalfOn';
    params.modulationContrast = [0.1 0.1 0.1];
    params.whichReceptorsToIsolate = [1 2 3];
    params.whichReceptorsToIgnore = [5 6 7 8];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% L+M+S-Directed
%     params.backgroundType = 'BackgroundHalfOn';
%     params.modulationDirection = 'LMinusMDirectedHalfOn';
%     params.modulationContrast = [0.05 -0.05];
%     params.whichReceptorsToIsolate = [1 2];
%     params.whichReceptorsToIgnore = [5 6 7 8];
%     params.whichReceptorsToMinimize = [];
%     params.receptorIsolateMode = 'Standard';
%     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%     [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
%     OLReceptorIsolateSaveCache(cacheData, olCache, params);
    
end