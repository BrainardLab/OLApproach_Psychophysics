function params = MakeDirectionCorrectedPrimaries(params)

% MakeDirectionCorrectedPrimaries - Make the corrected primaries from the nominal primaries
%
% Description:
%    The nominal primaries do not exactly have the desired properties,
%    because the OneLight does not exactly conform to its calibration
%    assumptions.  To deal with these, we use a spectrum seeking procedure
%    to tune up (aka "correct") the nominal primaries.  This routine does
%    that.
%
%    This is sufficiently time consuming that we only do it for the age of
%    the observer who is about to run.
%
%    The output is cached in the directory specified by
%    getpref('MaxPulsePsychophysics','DirectionCorrectedPrimariesDir');

% 6/18/17  dhb       Added header comments.  Renamed.
% 6/19/17  mab, jr   Added saving the cache data to the outDir location specified in OLCorrectCacheFileOOC.m  

% Modify with a "copy" versus "seek" flag.  This would determine whether it
% just copies over the nominal primaries (with appropriate name) or seeks
% and creates the whole shebang.

% Clear and close, set debugger if desired

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;

theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS' 'LightFluxMaxPulse' };
theDirectionsCorrect = [true true true]; 
spectroRadiometerOBJ=[];
% CorrectedPrimariesDir is MELA_materials.../DirectionNominalPrimaries
NominalPrimariesDir =  fullfile(getpref(params.approach, 'MaterialsPath'), 'Experiments',params.approach,'DirectionNominalPrimaries');
% materialsPath, please rename, and send to
% MELA_materials.../DirectionCorrectedPrimaries
CorrectedPrimariesDir = fullfile(getpref(params.approach, 'DataPath'), 'Experiments', params.approach, params.protocol, 'DirectionCorrectedPrimaries', params.observerID, params.todayDate, params.sessionName);
if(~exist(CorrectedPrimariesDir))
    mkdir(CorrectedPrimariesDir)
end

for d = 1:length(theDirections)
    % Print out some information
    fprintf(' * Direction:\t<strong>%s</strong>\n', theDirections{d});
    fprintf(' * Observer:\t<strong>%s</strong>\n', params.observerID);
    fprintf(' * Date:\t<strong>%s</strong>\n', params.todayDate);
    
    % Correct the cache
    fprintf(' * Starting spectrum-seeking loop...\n');

    % THIS IS OUR ATTEMPT TO DO IT THE OLD WAY WITH THE NEW CODE.
    [cacheData, olCache, spectroRadiometerOBJ, cal] = OLCorrectCacheFileOOC(...
        fullfile(NominalPrimariesDir, ['Direction_' theDirections{d} '.mat']), ...
        'jryan@mail.med.upenn.edu', ...
        'PR-670', spectroRadiometerOBJ, params.spectroRadiometerOBJWillShutdownAfterMeasurement, ...
        'FullOnMeas', false, ...
        'CalStateMeas', false, ...
        'DarkMeas', false, ...
        'OBSERVER_AGE', params.observerAgeInYrs, ...
        'ReducedPowerLevels', false, ...
        'selectedCalType', params.calibrationType, ...
        'CALCULATE_SPLATTER', false, ...
        'learningRate', 0.8, ...
        'learningRateDecrease', false, ...
        'asympLearningRateFactor',0.5, ...
        'smoothness', 0.1, ...
        'iterativeSearch', false, ...
        'NIter', 1, ...
        'powerLevels', [0 1.0000], ...
        'doCorrection', theDirectionsCorrect(d), ...
        'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
        'outDir', fullfile(CorrectedPrimariesDir, params.observerID), ... %fullfile(CorrectedPrimariesDir, 'MaxPulsePsychophysics', params.todayDate),
        'takeTemperatureMeasurements', params.takeTemperatureMeasurements, ...
        'useAverageGamma', false, ...
        'zeroPrimariesAwayFromPeak', false, ...
        'simulate', params.simulate, ...
        'approach', params.approach);

% THIS IS SET UP TO DO IT THE NEW WAY
%        [cacheData olCache spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
%         fullfile(NominalPrimariesDir, ['Direction_' theDirections{d} '.mat']), ...
%         'jryan@mail.med.upenn.edu', ...
%         'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
%         'FullOnMeas', false, ...
%         'CalStateMeas', false, ...
%         'DarkMeas', false, ...
%         'OBSERVER_AGE', params.observerAgeInYrs, ...
%         'ReducedPowerLevels', false, ...
%         'selectedCalType', theCalType, ...
%         'CALCULATE_SPLATTER', false, ...
%         'learningRate', 0.5, ...
%         'learningRateDecrease', true, ...
%         'asympLearningRateFactor',0.5, ...
%         'smoothness', 0.001, ...
%         'iterativeSearch', true, ...
%         'NIter', 25, ...
%         'powerLevels', [0 1.0000], ...
%         'doCorrection', theDirectionsCorrect(d), ...
%         'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
%         'outDir', fullfile(CorrectedPrimariesDir, params.observerID), ...
%         'takeTemperatureMeasurements', params.takeTemperatureMeasurements, ...
%         'useAverageGamma', true, ...
%         'zeroPrimariesAwayFromPeak', true);
    fprintf(' * Spectrum seeking finished!\n');
    
    % Save the cache
    fprintf(' * Saving cache ...');
    olCache = OLCache(CorrectedPrimariesDir,cal);
    %params = cacheData.data(params.observerAgeInYrs).describe.params;
    params.modulationDirection = theDirections{d};
    params.cacheFile = ['Direction_' params.modulationDirection '_' params.observerID '_' params.todayDate '.mat'];
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    fprintf('done!\n');
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end
toc;