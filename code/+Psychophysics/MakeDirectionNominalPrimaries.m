function MakeDirectionNominalPrimaries(baseParams)
% MaxPulsePsychophycis_MakeDirectionNominalPrimaries - Calculate the nominal modulation primaries for the experiment
%
% Description:
%     This script calculations the nominal primaries required for the
%     MaxPulsePsychopysics, for the extrema of the modulations.  Typically,
%     these will be tuned up by spectrum seeking on the day of the experiment.
%
%     The primaries depend on the calibration file and on the observer age.  This just precomputed
%     for the full range of observer ages.
%
%     The output is cached in the directory specified by
%     getpref('MaxPulsePsychophysics','DirectionNominalPrimariesPath');

% 6/18/17  dhb  Added header comment.
% 6/22/17  npc  Dictionarized direction params

% Make dictionary with direction-specific params for all directions
paramsDictionary = directionNominalParamsDictionary();

%% Silent substitution
% Melanopsin-directed
paramsMelDirected = directionParams(baseParams, paramsDictionary, 'MelanopsinDirected');
[cacheDataBackground, olCache, paramsMelDirected] = OLReceptorIsolateMakeBackgroundNominalPrimaries(paramsMelDirected, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, paramsMelDirected);

% MelanopsinDirectedSuperMaxMel
paramsMaxMel = directionParams(baseParams, paramsDictionary, 'MelanopsinDirectedSuperMaxMel');
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateMakeDirectionNominalPrimaries(paramsMaxMel, true);

% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxMel.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).backgroundSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differencePrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differenceSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end

% Save the modulations
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);


%% MaxLMS
paramsLMSDirected = directionParams(baseParams, paramsDictionary, 'LMSDirected');
[cacheDataBackground, olCache, paramsLMSDirected] = OLReceptorIsolateMakeBackgroundNominalPrimaries(paramsLMSDirected, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, paramsLMSDirected);

paramsMaxLMS = directionParams(baseParams, paramsDictionary, 'LMSDirectedSuperMaxLMS');
[cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS] = OLReceptorIsolateMakeDirectionNominalPrimaries(paramsMaxLMS, true);

% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differencePrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differenceSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end

% Save the cache
paramsMaxLMS.cacheFile = ['Cache-' paramsMaxLMS.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS);


%% Light flux
%
% For the light flux, we'd like a background that is the average
% chromaticity between the two MaxMel and MaxLMS backgrounds. The
% appropriate chromaticities are (approx.):
%   x = 0.54, y = 0.38

% Get the cal files
cal = LoadCalFile(OLCalibrationTypes.(baseParams.calibrationType).CalFileName, [], getpref('OneLight', 'OneLightCalData'));
cacheDir = fullfile(getpref(baseParams.approach, 'MaterialsPath'),'Experiments',baseParams.approach,'DirectionNominalPrimaries');

% Modulation 
desiredChromaticity = [0.54 0.38];
modPrimary = OLInvSolveChrom(cal, desiredChromaticity);

% Background
%
% This 5 here is hard coding the fact that we want a 400% light flux
% modulation.
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

% Save the cache?
paramsMaxPulseLightFlux.modulationDirection = 'LightFluxMaxPulse';
paramsMaxPulseLightFlux.cacheFile = ['Cache-' paramsMaxPulseLightFlux.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxPulseLightFlux, olCacheMaxPulseLightFlux, paramsMaxPulseLightFlux);
end


function dParams = directionParams(baseParams, paramsDictionary, directionName)
    % Check that requested directionName is valid and print available directions if it is not
    if (~paramsDictionary.isKey(directionName))
        availableDirections = keys(paramsDictionary);
        fprintf(2,'Known modulation directions\n');
        for k = 1:numel(availableDirections)
            fprintf(2,'[%d] ''%s''\n', k, availableDirections{k});
        end
        error('''%s'' is not a valid modulation direction', directionName);
    end
    % Get the direction specific params
    directionSpecificParams = paramsDictionary(directionName);
    % Update the params
    dParams = baseParams;
    for fn = fieldnames(directionSpecificParams)'
        dParams.(fn{1}) = directionSpecificParams.(fn{1});
    end
end

function d = directionNominalParamsDictionary()
    % Initialize dictionary
    d = containers.Map();
    
    %% MaxMel
    %
    % Note modulation contrast is typically 2/3 for 400% contrast or 66.66%
    % sinusoidal contrast, modulation contrast has been set to 20% for testing purposes
    directionName = 'MelanopsinDirected';
    params = struct();
    params.pegBackground = false;
    params.modulationDirection = {directionName};
    params.modulationContrast = [4/6];
    params.whichReceptorsToIsolate = {[4]};
    params.whichReceptorsToIgnore = {[]};
    params.whichReceptorsToMinimize = {[]};
    params.directionsYoked = [0];
    params.directionsYokedAbs = [0];
    params.receptorIsolateMode = 'Standard';
    params.backgroundType = 'BackgroundMaxMel';
    params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
    d(directionName) = params;
    
    
    %% MelanopsinDirectedSuperMaxMel
    directionName = 'MelanopsinDirectedSuperMaxMel';
    params = struct();
    params.primaryHeadRoom = 0.01;          % Original value: 0.005
    params.backgroundType = 'BackgroundMaxMel';
    params.modulationDirection = directionName;
    params.modulationContrast = [4/6];
    params.whichReceptorsToIsolate = [4];
    params.whichReceptorsToIgnore = [];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    d(directionName) = params;
    
    %% LMSdirected
    directionName = 'LMSDirected';
    params = struct();
    params.pegBackground = false;
    params.modulationDirection = {directionName};
    params.modulationContrast = {[4/6 4/6 4/6]};
    params.whichReceptorsToIsolate = {[1 2 3]};
    params.whichReceptorsToIgnore = {[]};
    params.whichReceptorsToMinimize = {[]};
    params.directionsYoked = [1];
    params.directionsYokedAbs = [0];
    params.receptorIsolateMode = 'Standard';
    params.backgroundType = 'BackgroundMaxLMS';
    params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
    d(directionName) = params;
    
    %% LMSdirectedSuperMaxMex
    directionName = 'LMSDirectedSuperMaxLMS';
    params = struct();
    params.primaryHeadRoom = 0.01;              % Original value 0.005
    params.backgroundType = 'BackgroundMaxLMS';
    params.modulationDirection = directionName;
    params.modulationContrast = [4/6 4/6 4/6];
    params.whichReceptorsToIsolate = [1 2 3];
    params.whichReceptorsToIgnore = [];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    d(directionName) = params;
end
