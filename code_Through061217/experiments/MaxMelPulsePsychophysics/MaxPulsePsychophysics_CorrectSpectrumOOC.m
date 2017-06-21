%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbstop if error;

% Ask for the observer age
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

% Query user whether to take temperature measurements
takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
if (takeTemperatureMeasurements ~= true) && (takeTemperatureMeasurements ~= 1)
   takeTemperatureMeasurements = false;
else
   takeTemperatureMeasurements = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
theCalType = 'BoxDRandomizedLongCableAStubby1_ND02';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS' 'LightFluxMaxPulse'};
theDirectionsCorrect = [true true true]; % Do not correct the third one (LightFluxMaxPulse)
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');

for d = 1:length(theDirections)
    % Print out some information
    fprintf(' * Direction:\t<strong>%s</strong>\n', theDirections{d});
    fprintf(' * Observer:\t<strong>%s</strong>\n', observerID);
    fprintf(' * Date:\t<strong>%s</strong>\n', todayDate);
    
    % Correct the cache
    fprintf(' * Starting spectrum-seeking loop...\n');

    % THIS IS OUR ATTEMPT TO DO IT THE OLD WAY WITH THE NEW CODE.
    [cacheData olCache spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
        fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
        'jryan@mail.med.upenn.edu', ...
        'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
        'FullOnMeas', false, ...
        'CalStateMeas', false, ...
        'DarkMeas', false, ...
        'OBSERVER_AGE', observerAgeInYrs, ...
        'ReducedPowerLevels', false, ...
        'selectedCalType', theCalType, ...
        'CALCULATE_SPLATTER', false, ...
        'learningRate', 0.8, ...
        'learningRateDecrease', false, ...
        'asympLearningRateFactor',0.5, ...
        'smoothness', 0.1, ...
        'iterativeSearch', false, ...
        'NIter', 20, ...
        'powerLevels', [0 1.0000], ...
        'doCorrection', theDirectionsCorrect(d), ...
        'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
        'outDir', fullfile(materialsPath, 'MaxMelPulsePsychophysics', todayDate), ...
        'takeTemperatureMeasurements', takeTemperatureMeasurements, ...
        'useAverageGamma', false, ...
        'zeroPrimariesAwayFromPeak', false);

% THIS IS SET UP TO DO IT THE NEW WAY
%        [cacheData olCache spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
%         fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
%         'jryan@mail.med.upenn.edu', ...
%         'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
%         'FullOnMeas', false, ...
%         'CalStateMeas', false, ...
%         'DarkMeas', false, ...
%         'OBSERVER_AGE', observerAgeInYrs, ...
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
%         'outDir', fullfile(materialsPath, 'MaxMelPulsePsychophysics', todayDate), ...
%         'takeTemperatureMeasurements', takeTemperatureMeasurements, ...
%         'useAverageGamma', true, ...
%         'zeroPrimariesAwayFromPeak', true);
    fprintf(' * Spectrum seeking finished!\n');
    
    % Save the cache
    fprintf(' * Saving cache ...');

    params = cacheData.data(observerAgeInYrs).describe.params;
    params.modulationDirection = theDirections{d};
    params.cacheFile = ['Cache-' params.modulationDirection '_' observerID '_' todayDate '.mat'];
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    fprintf('done!\n');
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end
toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the modulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make the mod
% LMS
tic;
customSuffix = ['_' observerID '_' todayDate];
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, theCalType, customSuffix);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, theCalType, customSuffix);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, theCalType, customSuffix);
toc;

% Assign the default choice index the first time we run this script. We
% clear this after the pre-experimental validation.
choiceIndex = 1;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Validate the spectrum before and after the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
commandwindow;

% Prompt the user to state if we're before or after the experiment
if ~exist('choiceIndex', 'var')
    choiceIndex = ChoiceMenuFromList({'Before the experiment', 'After the experiment'}, '> Validation before or after the experiment?');
end

% Ask for variables if they don't exist
if ~exist('observerID', 'var') || ~exist('observerAgeInYrs', 'var') || ~exist('todayDate', 'var') || ~exist('takeTemperatureMeasurements', 'var')
    observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
    observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
    todayDate = GetWithDefault('>> Enter <strong>date of modulations were created</strong>:', 'mmddyy');
    %todayDate = datestr(now, 'mmddyy');
    takeTemperatureMeasurements = true;
end

% Set up some parameters
theCalType = 'BoxDRandomizedLongCableAStubby1_ND02';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {['Cache-MelanopsinDirectedSuperMaxMel_' observerID '_' todayDate '.mat'] ...
    ['Cache-LMSDirectedSuperMaxLMS_' observerID '_' todayDate '.mat']};
NDirections = length(theDirections);
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');
NMeas = 5;

% Set up a counter
c = 1;
NTotalMeas = NMeas*NDirections;

for ii = 1:NMeas;
    for d = 1:NDirections
        % Inform the user where we are in the validation
        fprintf('*** Validation %g / %g in total ***\n', c, NTotalMeas);
        
        % We also take state measurements, which we define here
        if (choiceIndex == 1) && (c == 1)
            calStateFlag = true;
        elseif (choiceIndex == 2) && (c == NTotalMeas)
            calStateFlag = true;
        else
            calStateFlag = false;
        end
        
        % Take the measurement
        [~, ~, ~, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
            fullfile(cacheDir, 'stimuli', theDirections{d}), ...
            'jryan@mail.med.upenn.edu', ...
            'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
            'FullOnMeas', false, ...
            'CalStateMeas', calStateFlag, ...
            'DarkMeas', false, ...
            'OBSERVER_AGE', observerAgeInYrs, ...
            'ReducedPowerLevels', false, ...
            'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, ...
            'powerLevels', [0 1.0000], ...
            'pr670sensitivityMode', 'STANDARD', ...
            'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
            'outDir', fullfile(materialsPath, 'MaxMelPulsePsychophysics', datestr(now, 'mmddyy')), ...
            'takeTemperatureMeasurements', takeTemperatureMeasurements);
        
        % Increment the counter
        c = c+1;
    end
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end
fprintf('\n************************************************');
fprintf('\n*** <strong>Validation all complete</strong> ***');
fprintf('\n************************************************\n');
toc;

% Clear the choiceIndex. Note that this is only relevant for the
% pre-experimental validations.
clear choiceIndex;