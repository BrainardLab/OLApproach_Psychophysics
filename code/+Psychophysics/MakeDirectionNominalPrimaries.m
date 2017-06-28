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
% 6/22/17  npc  Dictionarized direction params, cleaned up.

    % Make dictionary with direction-specific params for all directions
    paramsDictionary = DirectionNominalParamsDictionary();

    %% Melanopsin-directed
    [paramsMelBackground, paramsMaxMel, cacheDataBackground, cacheDataMaxMel] = generateAndSavePrimaries(baseParams, paramsDictionary, 'MelanopsinDirected', 'MelanopsinDirectedSuperMaxMel');

    %% MaxLMS-directed
    [paramsLMSBackground, paramsMaxLMS, cacheDataBackground, cacheDataMaxLMS] = generateAndSavePrimaries(baseParams, paramsDictionary, 'LMSDirected', 'LMSDirectedSuperMaxLMS');

    %% Light flux
    %
    % For the light flux, we'd like a background that is the average
    % chromaticity between the two MaxMel and MaxLMS backgrounds. The
    % appropriate chromaticities are (approx.):
    %   x = 0.54, y = 0.38

    % Get the cal files
    cal = LoadCalFile(OLCalibrationTypes.(baseParams.calibrationType).CalFileName, [], fullfile(getpref(baseParams.approach, 'MaterialsPath'), 'Experiments',baseParams.approach,'OneLightCalData'));
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
    for observerAgeInYrs = 20:60
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).backgroundPrimary = bgPrimary;
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).backgroundSpd = [];
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).differencePrimary = modPrimary-bgPrimary;
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).differenceSpd = [];
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationPrimarySignedPositive = [];
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationSpdSignedPositive = [];
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
        cacheDataMaxPulseLightFlux.data(observerAgeInYrs).modulationSpdSignedNegative = [];
    end

    % Save the cache
    paramsMaxPulseLightFlux.modulationDirection = 'LightFluxMaxPulse';
    paramsMaxPulseLightFlux.cacheFile = ['Cache-' paramsMaxPulseLightFlux.modulationDirection '.mat'];
    OLReceptorIsolateSaveCache(cacheDataMaxPulseLightFlux, olCacheMaxPulseLightFlux, paramsMaxPulseLightFlux);
end

function [backgroundParams, maxDirectionParams, cacheDataBackground, cacheDataMaxDirection] = generateAndSavePrimaries(baseParams, paramsDictionary, backgroundDirectionName, maxDirectionName)
    % background direction
    backgroundParams = MergeBaseParamsWithParamsFromDictionaryEntry(baseParams, paramsDictionary, backgroundDirectionName);
    [cacheDataBackground, olCacheBackground, backgroundParams] = OLReceptorIsolateMakeBackgroundNominalPrimaries(backgroundParams, true);
    OLReceptorIsolateSaveCache(cacheDataBackground, olCacheBackground, backgroundParams);

    % max direction
    maxDirectionParams = MergeBaseParamsWithParamsFromDictionaryEntry(baseParams, paramsDictionary, maxDirectionName);
    [cacheDataMaxDirection, olCacheMaxDirection, maxDirectionParams] = OLReceptorIsolateMakeDirectionNominalPrimaries(maxDirectionParams, true);

    % Replace the backgrounds
    for observerAgeInYrs = 20:60
        cacheDataMaxDirection.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxDirection.data(observerAgeInYrs).modulationPrimarySignedNegative;
        cacheDataMaxDirection.data(observerAgeInYrs).backgroundSpd = cacheDataMaxDirection.data(observerAgeInYrs).modulationSpdSignedNegative;
        cacheDataMaxDirection.data(observerAgeInYrs).differencePrimary = cacheDataMaxDirection.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxDirection.data(observerAgeInYrs).modulationPrimarySignedNegative;
        cacheDataMaxDirection.data(observerAgeInYrs).differenceSpd = cacheDataMaxDirection.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxDirection.data(observerAgeInYrs).modulationSpdSignedNegative;
        cacheDataMaxDirection.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
        cacheDataMaxDirection.data(observerAgeInYrs).modulationSpdSignedNegative = [];
    end

    % Save the modulations
    OLReceptorIsolateSaveCache(cacheDataMaxDirection, olCacheMaxDirection, maxDirectionParams);
end


