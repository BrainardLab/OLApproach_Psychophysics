function HCLV_Photo_Prep

whichScanner = GetWithDefault('>>> Which scanner will you be using?', '3T');
switch whichScanner
    case {'3T', '7T'}
        % OK
    otherwise
        error('Come back in the future. This scanner does not exist.');
end


%% Set up options
theOptions = {'Calibrate the OneLight' ; ...
    'Generate isolating primary settings' ; ...
    'Spectrum-seeking + validation' ; ...
    'Validate isolating primary settings' ; ...
    'Generate the modulation cfg files' ; ...
    'Generate the modulations' ; ...
    'Make the protocol files and add to master protocol list' ; ...
    'Exit'};

%% Prompt for choice on the options
numAvailOptions = length(theOptions);
keepPrompting = true;
while keepPrompting
    % Show the available calibration types.
    fprintf('\n*** Available options ***\n\n');
    for i = 1:length(theOptions)
        fprintf('\t%d - %s\n', i, theOptions{i});
    end
    fprintf('\n');
    
    optIndex = GetInput('Select a option', 'number', 1);
    
    % Check the selection.
    if optIndex >= 1 && optIndex <= numAvailOptions
        keepPrompting = false;
    else
        fprintf('\n* Invalid selection\n');
    end
end

%% Set up some master parameters
% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'HCLVPhoto';
params.whichScanner = whichScanner;
switch params.whichScanner
    case '7T'
        params.calibrationType = 'BoxCRandomizedLongCableCStubby1NoLens_ND10_ContactLens_0_5mm';
    case '3T'
        params.calibrationType = 'BoxBRandomizedLongCableBStubby1_ND02';
end
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LCone2DegTabulatedSS,MCone2DegTabulatedSS,SCone2DegTabulatedSS,LCone10DegTabulatedSS,MCone10DegTabulatedSS,SCone10DegTabulatedSS';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;

switch optIndex
    case 1
        OLCalibrateOOC;
    case 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAKE THE PHOTORECEPTOR-DIRECTED MODULATIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Make optimal background
        params.pegBackground = false;
        params.backgroundType = 'BackgroundHalfOn';
        params.modulationDirection = {'MelanopsinDirected'};
        params.modulationContrast = [];
        params.whichReceptorsToIsolate = {[7]};
        params.whichReceptorsToIgnore = {[]};
        params.whichReceptorsToMinimize = {[]};
        params.directionsYoked = [0];
        params.directionsYokedAbs = [0];
        params.receptorIsolateMode = 'Standard';
        params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
        [cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
        OLReceptorIsolateSaveCache(cacheData, olCache, params);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2° & 10° targeted
        % LMS
        params.backgroundType = 'BackgroundHalfOn';
        params.modulationDirection = 'LightFluxXEccentricity';
        params.modulationContrast = [0.9];
        params.whichReceptorsToIsolate = [1 2 3 4 5 6];
        params.whichReceptorsToIgnore = [];
        params.whichReceptorsToMinimize = [];
        params.receptorIsolateMode = 'Standard';
        params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
        [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
        OLReceptorIsolateSaveCache(cacheData, olCache, params);
        
        % 2° & 10° targeted
        % L-M
        params.backgroundType = 'BackgroundHalfOn';
        params.modulationDirection = 'LMinusMDirectedXEccentricity';
        params.modulationContrast = [0.08 -0.08 0.08 -0.08];
        params.whichReceptorsToIsolate = [1 2 4 5];
        params.whichReceptorsToIgnore = [];
        params.whichReceptorsToMinimize = [];
        params.receptorIsolateMode = 'Standard';
        params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
        [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
        OLReceptorIsolateSaveCache(cacheData, olCache, params);
        
        % 2° & 10° targeted
        % S
        params.backgroundType = 'BackgroundHalfOn';
        params.modulationDirection = 'SDirectedXEccentricity';
        params.modulationContrast = [0.5 0.5];
        params.whichReceptorsToIsolate = [3 6];
        params.whichReceptorsToIgnore = [];
        params.whichReceptorsToMinimize = [];
        params.receptorIsolateMode = 'Standard';
        params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
        [cacheData, olCache, params] = OLReceptorIsolateMakeDirectionNominalPrimaries(params, true);
        OLReceptorIsolateSaveCache(cacheData, olCache, params);
        
    case 3
        
        commandwindow;
        observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
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
        theCalType = params.calibrationType;
        spectroRadiometerOBJ = [];
        spectroRadiometerOBJWillShutdownAfterMeasurement = false;
        theDirections = {'LightFluxXEccentricity' 'LMinusMDirectedXEccentricity' 'SDirectedXEccentricity'};
        theDirectionsCorrect = [true true true];
        cacheDir = getpref('OneLight', 'cachePath');
        materialsPath = getpref('OneLight', 'materialsPath');
        
        for d = 1:length(theDirections)
            % Print out some information
            fprintf(' * Direction:\t<strong>%s</strong>\n', theDirections{d});
            fprintf(' * Observer:\t<strong>%s</strong>\n', observerID);
            fprintf(' * Date:\t<strong>%s</strong>\n', todayDate);
            
            % Correct the cache
            fprintf(' * Starting spectrum-seeking loop...\n');
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
                'lambda', 0.8, ...
                'NIter', 10, ...
                'powerLevels', [0 1.0000], ...
                'doCorrection', theDirectionsCorrect(d), ...
                'postreceptoralCombinations', [1 1 1 0 0 0 ; 0 0 0 1 1 1 ; 1 -1 0 0 0 0 ; 0 0 0 1 -1 0 ; 0 0 1 0 0 0 ; 0 0 0 0 0 1], ...
                'outDir', fullfile(materialsPath, 'PIPRMaxPulse', todayDate), ...
                'takeTemperatureMeasurements', takeTemperatureMeasurements);
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
        
    case 4
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % VALIDATION THE PHOTORECEPTOR-DIRECTED MODULATIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        
        commandwindow;
        observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
        observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
        todayDate = datestr(now, 'mmddyy');
        theDirections = {['LightFluxXEccentricity_' observerID '_' todayDate] ...
        ['LMinusMDirectedXEccentricity_' observerID '_' todayDate] ...
        ['SDirectedXEccentricity_' observerID '_' todayDate]};
        
        % Query user whether to take temperature measurements
        takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
        if (takeTemperatureMeasurements ~= true) && (takeTemperatureMeasurements ~= 1)
           takeTemperatureMeasurements = false;
        else
           takeTemperatureMeasurements = true;
        end
        
        spectroRadiometerOBJ = [];
        spectroRadiometerOBJWillShutdownAfterMeasurement = false;
        for i = 1:5

            cacheDir = getpref('OneLight', 'cachePath');
            materialsPath = getpref('OneLight', 'materialsPath');
            
            WaitSecs(2);
            for d = 1:length(theDirections)
                
                % Print out some information
                fprintf(' * Direction:\t<strong>%s</strong>\n', theDirections{d});
                fprintf(' * Observer:\t<strong>%s</strong>\n', observerID);
                fprintf(' * Date:\t<strong>%s</strong>\n', todayDate);
                
                [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
                    fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
                    'jryan@mail.med.upenn.edu', ...
                    'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
                    'FullOnMeas', false, ...
                    'ReducedPowerLevels', false, ...
                    'selectedCalType', params.calibrationType, ...
                    'CALCULATE_SPLATTER', false, ...
                    'powerLevels', [0 1.0000], ...
                    'postreceptoralCombinations', [1 1 1 0 0 0 ; 0 0 0 1 1 1 ; 1 -1 0 0 0 0 ; 0 0 0 1 -1 0 ; 0 0 1 0 0 0 ; 0 0 0 0 0 1], ...
                    'outDir', fullfile(materialsPath, 'HCLV_Photo', datestr(now, 'mmddyy')), ...
                    'takeTemperatureMeasurements', takeTemperatureMeasurements);
                close all;
            end
        end % loop over iterations
        if (~isempty(spectroRadiometerOBJ))
            spectroRadiometerOBJ.shutDown();
            spectroRadiometerOBJ = [];
        end
        
        
    case 5
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAKE THE STIMULUS FILES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        % Make the different directions
        maxContrasts = [0.9 0.8 0.50];
        theDirections = {'LightFluxXEccentricity' 'LMinusMDirectedXEccentricity' 'SDirectedXEccentricity'};
        for d = 1:length(theDirections)
            % Make the config file
            % Create an empty config file
            basePath = '/Users/melanopsin/Documents/MATLAB/projects/Experiments/OLFlickerSensitivity/code/config/modulations';
            modulationFileName = ['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation' params.whichScanner '.cfg'];
            fullPathCfgFile = fullfile(basePath, modulationFileName);
            fclose(fopen(fullPathCfgFile, 'w'));
            
            % Make a cfg file struct
            cfgFile = ConfigFile(fullPathCfgFile);
            
            % Add parameters
            cfgFile = addParam(cfgFile, 'trialDuration', 'd', '12', 'Total duration of segment');
            cfgFile = addParam(cfgFile, 'timeStep', 'd', '1/256', 'Time step');
            cfgFile = addParam(cfgFile, 'cosineWindowIn', 'd', '1', 'Cosine windowing at onset?');
            cfgFile = addParam(cfgFile, 'cosineWindowOut', 'd', '1', 'Cosine windowing at offset?');
            cfgFile = addParam(cfgFile, 'cosineWindowDurationSecs', 'd', '1.5', 'Duration of cosine window');
            cfgFile = addParam(cfgFile, 'nFrequencies', 'd', '7', 'Number of frequencies'); % The number of frequencies are defined here
            cfgFile = addParam(cfgFile, 'nPhases', 'd', '1', 'Number of phases');
            cfgFile = addParam(cfgFile, 'phaseRandSec', 'd', '[]', 'Empty here');
            cfgFile = addParam(cfgFile, 'modulationMode', 's', 'FM', 'Total duration of each trial');
            cfgFile = addParam(cfgFile, 'modulationWaveForm', 's', 'sin', 'Parametric form');
            cfgFile = addParam(cfgFile, 'modulationFrequencyTrials', 'd', '[]', 'Sequence of modulation frequencies');
            cfgFile = addParam(cfgFile, 'modulationPhase', 'd', '[]', 'Phases of envelope');
            cfgFile = addParam(cfgFile, 'carrierFrequency', 'd', '[0 2 4 8 16 32 64]', 'Frequencies used'); % The frequencies are defined here
            cfgFile = addParam(cfgFile, 'carrierPhase', 'd', '[0]', 'Phases of carrier');
            cfgFile = addParam(cfgFile, 'nContrastScalars', 'd', '1', 'Number of different contrast scales');
            cfgFile = addParam(cfgFile, 'contrastScalars', 'd', '[1]', 'Contrast scalars (as proportion of max.)');
            cfgFile = addParam(cfgFile, 'maxContrast', 'd', num2str(maxContrasts(d)), 'Max. contrast');
            cfgFile = addParam(cfgFile, 'direction', 's', [theDirections{d}], 'Name of modulation direction');
            cfgFile = addParam(cfgFile, 'directionCacheFile', 's', ['Cache-' theDirections{d} '.mat'], 'Cache file to be used');
            cfgFile = addParam(cfgFile, 'preCacheFile', 's', ['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation' params.whichScanner '.mat'], 'Output file name');
            
            cfgFile = setRawText(cfgFile, ['% 12s flicker of ' theDirections{d} '  flicker at 0, 2, 4, 8, 16, 32 and 64 Hz, ' datestr(now, 30)]);
            
            % Write to file
            cfgFile.write;
        end
        
        
        %%
        % Make the scotopic file
        theDirections = {'LightFluxXEccentricity'};
        for d = 1:length(theDirections)
            % Make the config file
            % Create an empty config file
            basePath = '/Users/melanopsin/Documents/MATLAB/projects/Experiments/OLFlickerSensitivity/code/config/modulations';
            modulationFileName = ['Modulation-' theDirections{d} 'Scotopic-12sWindowedFrequencyModulation' params.whichScanner '.cfg'];
            fullPathCfgFile = fullfile(basePath, modulationFileName);
            fclose(fopen(fullPathCfgFile, 'w'));
            
            % Make a cfg file struct
            cfgFile = ConfigFile(fullPathCfgFile);
            
            % Add parameters
            cfgFile = addParam(cfgFile, 'trialDuration', 'd', '12', 'Total duration of segment');
            cfgFile = addParam(cfgFile, 'timeStep', 'd', '1/256', 'Time step');
            cfgFile = addParam(cfgFile, 'cosineWindowIn', 'd', '1', 'Cosine windowing at onset?');
            cfgFile = addParam(cfgFile, 'cosineWindowOut', 'd', '1', 'Cosine windowing at offset?');
            cfgFile = addParam(cfgFile, 'cosineWindowDurationSecs', 'd', '1.5', 'Duration of cosine window');
            cfgFile = addParam(cfgFile, 'nFrequencies', 'd', '7', 'Number of frequencies'); % The number of frequencies are defined here
            cfgFile = addParam(cfgFile, 'nPhases', 'd', '1', 'Number of phases');
            cfgFile = addParam(cfgFile, 'phaseRandSec', 'd', '[]', 'Empty here');
            cfgFile = addParam(cfgFile, 'modulationMode', 's', 'FM', 'Total duration of each trial');
            cfgFile = addParam(cfgFile, 'modulationWaveForm', 's', 'sin', 'Parametric form');
            cfgFile = addParam(cfgFile, 'modulationFrequencyTrials', 'd', '[]', 'Sequence of modulation frequencies');
            cfgFile = addParam(cfgFile, 'modulationPhase', 'd', '[]', 'Phases of envelope');
            cfgFile = addParam(cfgFile, 'carrierFrequency', 'd', '[0 0.5 1 2 4 8 16]', 'Frequencies used'); % The frequencies are defined here
            cfgFile = addParam(cfgFile, 'carrierPhase', 'd', '[0]', 'Phases of carrier');
            cfgFile = addParam(cfgFile, 'nContrastScalars', 'd', '1', 'Number of different contrast scales');
            cfgFile = addParam(cfgFile, 'contrastScalars', 'd', '[1]', 'Contrast scalars (as proportion of max.)');
            cfgFile = addParam(cfgFile, 'direction', 's', [theDirections{d} 'Scotopic'], 'Name of modulation direction');
            cfgFile = addParam(cfgFile, 'directionCacheFile', 's', ['Cache-' theDirections{d} '.mat'], 'Cache file to be used');
            cfgFile = addParam(cfgFile, 'preCacheFile', 's', ['Modulation-' theDirections{d} 'Scotopic-12sWindowedFrequencyModulation' params.whichScanner '.mat'], 'Output file name');
            
            cfgFile = setRawText(cfgFile, ['% 12s flicker of ' theDirections{d} '  flicker at 0, 2, 4, 8, 16, 32 and 64 Hz, ' datestr(now, 30)]);
            
            % Write to file
            cfgFile.write;
        end
    case 6
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAKE THE STIMULI FOR A GIVEN OBSERVER
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        observerAges = GetWithDefault('>>> Please enter observer ages', 32);
        theDirections = {'LightFluxXEccentricity' 'LMinusMDirectedXEccentricity' 'SDirectedXEccentricity'};
        for d = 1:length(theDirections)
            % Make the modulation
            modulationFileName = ['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation' params.whichScanner '.cfg'];
            
            for o = 1:length(observerAges)
                OLReceptorIsolateMakeModulationStartsStops(modulationFileName, observerAges(o), params.calibrationType, params.calibrationType);
            end
        end
        
        
        
    case 7
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAKE THE PROTOCOL FILES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        % Create an empty config file
        % Make the different directions
        theDirections = {'LightFluxXEccentricity' 'LMinusMDirectedXEccentricity' 'SDirectedXEccentricity'};
        frequencyOrder = {'[5 2 4 5 7 2 5 4 2 7 3 6 5 1 2 3 7 6 1 7 1 3 5 6 4 1 1 1]' ...
            '[1 6 6 2 1 5 3 2 2 6 7 4 6 3 3 4 4 3 1 1 4 7 7 5 5 1 1 1]'};
        runID = {'A', 'B'};
        for d = 1:length(theDirections)
            for r = 1:length(runID)
                basePath = '/Users/melanopsin/Documents/MATLAB/projects/Experiments/OLFlickerSensitivity/code/config/protocols';
                modulationName = [params.experimentSuffix '-300s' theDirections{d} '12sSegments' params.whichScanner '-' runID{r}];
                modulationFileName = [modulationName '.cfg'];
                fullPathCfgFile = fullfile(basePath, modulationFileName);
                fclose(fopen(fullPathCfgFile, 'w'));
                
                % Make a cfg file struct
                cfgFile = ConfigFile(fullPathCfgFile);
                
                % Add parameters
                cfgFile = addParam(cfgFile, 'calibrationType', 's', params.calibrationType, 'Calibration Type');
                cfgFile = addParam(cfgFile, 'timeStep', 'd', '1/256', 'Time step');
                cfgFile = addParam(cfgFile, 'nTrials', 'd', '28', 'Number of trials');
                cfgFile = addParam(cfgFile, 'theFrequencyIndices', 'd', frequencyOrder{r}, 'Sequence of indices into frequency');
                cfgFile = addParam(cfgFile, 'thePhaseIndices', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Sequence of indices into phase');
                cfgFile = addParam(cfgFile, 'theDirections', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Sequence of indices into direction');
                cfgFile = addParam(cfgFile, 'theContrastRelMaxIndices', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Sequence of indices into contrast scalar');
                cfgFile = addParam(cfgFile, 'trialDuration', 'd', '[12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12]', 'Trial durations');
                cfgFile = addParam(cfgFile, 'modulationFiles', 's', ['Modulation-' theDirections{d} '-12sWindowedFrequencyModulation' params.whichScanner '.mat'], 'Modulation name');
                cfgFile = addParam(cfgFile, 'checkKB', 'd', '1', 'Check keyboard?');
                cfgFile = addParam(cfgFile, 'waitForKeyPress', 'd', '1', 'Wait for key press?');
                cfgFile = addParam(cfgFile, 'attentionTask', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Attention task per segment?');
                cfgFile = addParam(cfgFile, 'attentionProbability', 'd', '0.333', 'Probability of attenion task');
                cfgFile = addParam(cfgFile, 'attentionMarginDuration', 'd', '2', 'Margin in seconds in which we cannot have have a dimming');
                cfgFile = addParam(cfgFile, 'attentionSegmentDuration', 'd', '12', 'Duration of segment of the trial duration in which the dimming occurs');
                cfgFile = addParam(cfgFile, 'attentionBlankDuration', 'd', '0.25', 'Duration in seconds of the blank durations');
                cfgFile = addParam(cfgFile, 'phaseRandSec', 'd', '[]', 'Empty for this protocol');
                
                cfgFile = setRawText(cfgFile, ['% 25 segments of 12s '  ' flicker, ' datestr(now, 30)]);
                
                % Write to file
                cfgFile.write;
                
                % Add the protocol to the master config file
                basePath = '/Users/melanopsin/Documents/MATLAB/projects/Experiments/OLFlickerSensitivity/code/config/';
                fileName = 'OLFlickerSensitivityProtocols.cfg';
                
                name = modulationName;
                configFile = modulationFileName;
                driver = 'ModulationTrialSequenceMR';
                dataDirectory = ['HCLV_Photo_' params.whichScanner];
                
                fid = fopen(fullfile(basePath, fileName), 'a');
                fprintf(fid, '\n%s\t%s\t%s\t%s', name, configFile, driver, dataDirectory);
                fclose(fid);
            end
        end
    case 8
        % Do nothing
end

end
