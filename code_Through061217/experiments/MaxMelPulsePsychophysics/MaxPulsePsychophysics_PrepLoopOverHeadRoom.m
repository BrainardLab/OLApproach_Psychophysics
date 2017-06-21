%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the cache
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxARandomizedLongCableBStubby1_ND02';
headRoomVals = [0.01:0.01:0.2];
nheadRoomVals = length(headRoomVals);

% Now, make the modulation
%Original value: 0.005
for ii = 1:nheadRoomVals
    
    %% Standard parameters
    params.experiment = 'MaxMelPulsePsychophysics';
    params.experimentSuffix = 'MaxMelPulsePsychophysics';
    params.calibrationType = theCalType;
    params.whichReceptorsToMinimize = [];
    params.CALCULATE_SPLATTER = false;
    params.maxPowerDiff = 10^(-1);
    params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
    params.fieldSizeDegrees = 27.5;
    params.pupilDiameterMm = 8; % Assuming dilated pupil
    params.isActive = 1;
    params.useAmbient = 1;
    params.REFERENCE_OBSERVER_AGE = 32;
    %Original value 0.01
    params.primaryHeadRoom = is;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Silent substitution
    %% MaxMel
    params.pegBackground = false;
    params.modulationDirection = {'MelanopsinDirected'};
    % Note modulation contrast is typically 2/3 for 400% contrast or 66.66%
    % sinusoidal contrast, modulation contrast has been set to 20% for testing
    % purposes
    params.modulationContrast = [];
    params.whichReceptorsToIsolate = {[4]};
    params.whichReceptorsToIgnore = {[]};
    params.whichReceptorsToMinimize = {[]};
    params.directionsYoked = [0];
    params.directionsYokedAbs = [0];
    params.receptorIsolateMode = 'Standard';
    
    %params.primaryHeadRoom = is;
    % Mel shifted background
    params.backgroundType = 'BackgroundMaxMel';
    params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
    [cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
    OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);
    
    is = headRoomVals(ii);
    
    params.backgroundType = 'BackgroundMaxMel';
    params.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
    params.modulationContrast = [];
    params.whichReceptorsToIsolate = [4];
    params.whichReceptorsToIgnore = [];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    [cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
    allContrasts(:, ii) = cacheDataMaxMel.data(32).describe.contrastSignedPositive;
end
subplot(1, 2, 1); plot(headRoomVals, allContrasts(4, :), '-sk'); xlabel('Headroom'); ylabel('Max. contrast'); ylim([0 0.9]); xlim([0 0.21]); pbaspect([1 1 1]);
title('Sinusoidal contrast');
subplot(1, 2, 2); plot(headRoomVals, (2*allContrasts(4, :))./(1-allContrasts(4, :)), '-sk'); xlabel('Headroom'); ylabel('Max. contrast'); ylim([0 6]); xlim([0 0.21]); pbaspect([1 1 1]);
title('Unipolar contrast');

%% MaxLMS
params.pegBackground = false;
params.modulationDirection = {'LMSDirected'};
params.modulationContrast = {[2/3 2/3 2/3]};
params.whichReceptorsToIsolate = {[1 2 3]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [1];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';
headRoomVals = [0.0100 0.0200 0.0300 0.0400 0.0500 0.0600 0.0700 0.0800 0.0900 0.1000 0.1100 0.1200 0.1300 0.1400 0.1500 0.1600 0.1700 0.1800 0.1900 0.2000];
nheadRoomVals = length(headRoomVals);

% LMS shifted background
params.backgroundType = 'BackgroundMaxLMS';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
% Original value 0.005
for ii = 1:nheadRoomVals
    is = headRoomVals(ii)
    params.primaryHeadRoom = is;
    params.backgroundType = 'BackgroundMaxLMS';
    params.modulationDirection = 'LMSDirectedSuperMaxLMS';
    params.modulationContrast = [2/3 2/3 2/3];
    params.whichReceptorsToIsolate = [1 2 3];
    params.whichReceptorsToIgnore = [];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    [cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
    % Replace the backgrounds
    for observerAgeInYrs = [20:60]
        cacheDataMaxLMS.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
        cacheDataMaxLMS.data(observerAgeInYrs).backgroundSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
        cacheDataMaxLMS.data(observerAgeInYrs).differencePrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
        cacheDataMaxLMS.data(observerAgeInYrs).differenceSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
        cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
        cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative = [];
    end
    paramsMaxLMS.modulationDirection = 'LMSDirectedSuperMaxLMS';
    paramsMaxLMS.cacheFile = ['Cache-' paramsMaxLMS.modulationDirection, num2str(is), '.mat'];
    OLReceptorIsolateSaveCache(cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS);
end
%% Light flux
%% For the light flux, we'd like a background that is the average chromaticity
% between the two MaxMel and MaxLMS backgrounds. These are (approx.):
%   x = 0.54, y = 0.38

% Get the cal files
cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName, [], getpref('OneLight', 'OneLightCalData'));
cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');

% Modulation
desiredChromaticity = [0.54 0.38];
modPrimary = OLInvSolveChrom(cal, desiredChromaticity);

% Background
bgPrimary = modPrimary/5;

% We copy over the information from the LMS cache file
cacheDataMaxPulseLightFlux = cacheDataMaxLMS;
paramsMaxPulseLightFlux = paramsMaxLMS;

% Set up the cache structure
olCacheMaxPulseLightFlux = OLCache(cacheDir, cal);

% Replace the values
for observerAgeInYrs = [20:60]
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).backgroundPrimary = bgPrimary;
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).backgroundSpd = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).differencePrimary = modPrimary-bgPrimary;
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).differenceSpd = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationPrimarySignedPositive = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationSpdSignedPositive = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxPulseLightFlux.modulationDirection = 'LightFluxMaxPulse';
paramsMaxPulseLightFlux.cacheFile = ['Cache-' paramsMaxPulseLightFlux.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxPulseLightFlux, olCacheMaxPulseLightFlux, paramsMaxPulseLightFlux);