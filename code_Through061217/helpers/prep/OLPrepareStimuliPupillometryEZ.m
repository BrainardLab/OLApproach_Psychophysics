% OLPrepareStimuliPupillometryEZ
%
% OVERVIEW
%
% This script generates the necessary cache files and modulation files for
% pupillometry experiments. There are two levels of pre-cached information.
%
%   a) Cache files, which contain the primary settings for a given
%      modulation.
%   b) Modulation files, which contain the fully computed mirror settings
%      for a given modulation direction, for the specified frequency, phase
%      setting, and contrast. These are pre-cached since the way that we
%      calculate mirror settings from primary values can turn out to be
%      computationally expensive at run time.
%
% FUNCTIONS
%
% This script can perform the following functions:
%   1) Calibrate the OneLight
%   2) Generate isolating primary settings
%   3) Validate isolating primary settings
%   4) Generate modulations
%
% USAGE
%
% For a typical calibration, steps 1-4 are performed.
%
% Everytime step 1 (calibration) is run, steps 2-4 have to follow.
% Everytime step 2 (generation) is run, steps 3-4 have to follow.
% Typically, though, steps 2 and 4 are run after the calibration.
%
% It is recommended that before and after each experimental subject is run,
% step 3 is run. This allows us to assess any drift from calibration.
%
% Everytime the script is run, only one step is performed AT A TIME. That
% is, if you want to first calibrate, run the script. If you want to
% generate isolating primary settings, run the script again and the select
% the corresponding option.
%
% Questions? Email mspits@sas.upenn.edu.
%
% History:
%
% 7/20/14       spitschan       Written.

%% Dump out comments
tmp = mfilename;
eval(['help  ' tmp]);

%% Add to path
addpath(genpath('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/'));

%% Set up options
theOptions = {'Calibrate the OneLight' ; ...
    'Generate isolating primary settings' ; ...
    'Validate isolating primary settings' ; ...
    'Exit (with OneLight shutdown)' ; ...
    'Generate modulations' ; ...
    'Exit (without OneLight shutdown)'};

%% Prompt for choice on the options
numAvailOptions = length(theOptions);
keepPrompting = true;
while keepPrompting
    % Show the available calibration types.
    fprintf('\n*** Available options ***\n\n');
    for i = 1:length(theOptions)
        fprintf('%d - %s\n', i, theOptions{i});
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

%% Infinite loop
keepOuterLoop = true;
while keepOuterLoop
    
    %% Evaluate the choice.
    switch optIndex
        case 1
            fprintf('Starting calibration. Instructions below.\n');
            fprintf('BoxBLongCableAEyePiece2 typical for July 2014.\n');
            OLCalibrate;
        case 2
            fprintf('Generating cache files. These will be generated following calibration.\n');
            fprintf('Splatter maps will be generated. This process might take some time.\n');
            
            theModulationTypes = {'Standard set (BoxBLongCableAEyePiece2): LMDirected, SDirected, MelanopsinDirectedLegacy, MelanopsinDirected, Isochromatic, KleinSilent)' ; ...
                'PIPR set (BoxBLongCableAEyePiece2): PIPR470, PIPR623' ; ...
                'Interaction set (BoxBLongCableAEyePiece2): LMDirectedHighMel, LMDirectedLowMel' ; ...
                'Rod scatter control (BoxBLongCableBEyePiece1BeamsplitterProjectorOn, BoxBLongCableBEyePiece1BeamsplitterProjectorOff): MelanopsinDirectedLegacy, SDirected'};
            
            %% Prompt for choice on the options
            numAvailOptions = length(theModulationTypes);
            keepPrompting = true;
            while keepPrompting
                % Show the available calibration types.
                fprintf('\n*** Available options ***\n\n');
                for i = 1:length(theModulationTypes)
                    fprintf('%d - %s\n', i, theModulationTypes{i});
                end
                fprintf('\n');
                
                modIndex = GetInput('Select a option', 'number', 1);
                
                % Check the selection.
                if modIndex >= 1 && modIndex <= numAvailOptions
                    keepPrompting = false;
                else
                    fprintf('\n* Invalid selection\n');
                end
            end
            
            switch modIndex
                case 1
                    %% Standard parameters
                    params.experiment = 'OLFlickerSensitivity';
                    params.experimentSuffix = 'Pupillometry';
                    theCalType = 'BoxBLongCableAEyePiece2';
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
                    
                    
                    %%% MAIN MODULATIONS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% LMinusMDirected
                    params.modulationDirection = 'LMinusMDirected';
                    params.modulationContrast = [0.13 -0.13];
                    params.whichReceptorsToIsolate = [1 2];
                    params.whichReceptorsToIgnore = [5 6 7];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    
                    %% LMDirected
                    params.modulationDirection = 'LMDirected';
                    params.modulationContrast = [0.45 0.45];
                    params.whichReceptorsToIsolate = [1 2];
                    params.whichReceptorsToIgnore = [5 6 7];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% SDirected
                    params.modulationDirection = 'SDirected';
                    params.modulationContrast = [0.45];
                    params.whichReceptorsToIsolate = [3];
                    params.whichReceptorsToIgnore = [5 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% MelanopsinDirected
                    params.modulationDirection = 'MelanopsinDirected';
                    params.modulationContrast = [0.2];
                    params.whichReceptorsToIsolate = [4];
                    params.whichReceptorsToIgnore = [5];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% MelanopsinDirectedLegacy - not silencing penumbral cones
                    params.modulationDirection = 'MelanopsinDirectedLegacy';
                    params.modulationContrast = [0.45];
                    params.whichReceptorsToIsolate = [4];
                    params.whichReceptorsToIgnore = [5 6 7 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% Isochromatic
                    params.modulationDirection = 'Isochromatic';
                    params.modulationContrast = [0.45];
                    params.whichReceptorsToIsolate = [];
                    params.whichReceptorsToIgnore = [];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    
                case 2
                    %% Standard parameters
                    params.experiment = 'OLFlickerSensitivity';
                    params.experimentSuffix = 'Pupillometry';
                    theCalType = 'BoxBLongCableAEyePiece2';
                    params.calibrationType = theCalType;
                    params.whichReceptorsToMinimize = [];
                    params.CALCULATE_SPLATTER = true;
                    params.maxPowerDiff = 10^(-1.5);
                    params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
                    params.fieldSizeDegrees = 27.5;
                    params.isActive = 1;
                    params.useAmbient = 1;
                    params.REFERENCE_OBSERVER_AGE = 32;
                    params.primaryHeadRoom = 0.02;
                    
                    
                    %%% PIPR
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% PIPR - 'blue'
                    params.modulationDirection = 'PIPR470';
                    params.modulationContrast = [];
                    params.whichReceptorsToIsolate = [];
                    params.whichReceptorsToIgnore = [];
                    params.receptorIsolateMode = 'PIPR';
                    params.bgOperatingPoint = 0.1;
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateFindPIPR(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %% PIPR - 'red'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    params.modulationDirection = 'PIPR623';
                    params.modulationContrast = [];
                    params.whichReceptorsToIsolate = [];
                    params.whichReceptorsToIgnore = [];
                    params.receptorIsolateMode = 'PIPR';
                    params.bgOperatingPoint = 0.1;
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateFindPIPR(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                case 3
                    %% Standard parameters
                    params.experiment = 'OLFlickerSensitivity';
                    params.experimentSuffix = 'Pupillometry';
                    theCalType = 'BoxBLongCableAEyePiece2';
                    params.calibrationType = theCalType;
                    params.whichReceptorsToMinimize = [];
                    params.CALCULATE_SPLATTER = true;
                    params.maxPowerDiff = 10^(-1.5);
                    params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
                    params.fieldSizeDegrees = 27.5;
                    params.isActive = 1;
                    params.useAmbient = 1;
                    params.REFERENCE_OBSERVER_AGE = 32;
                    params.primaryHeadRoom = 0.02;
                    
                    %%% INTERACTION MODULATIONS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% LMDirected - high melanopsin background
                    params.modulationDirection = 'LMDirectedHighMel';
                    params.modulationContrast = [0.2 0.2];
                    params.whichReceptorsToIsolate = [1 2];
                    params.whichReceptorsToIgnore = [5 6 7];
                    params.receptorIsolateMode = 'Standard';
                    
                    % Set up the background optimization. We first create the
                    % melanopsin-isolating modulation, which we then use as the background.
                    params.background.modulationDirection = 'MelanopsinDirectedLegacy';
                    params.background.modulationContrast = [0.30];
                    params.background.whichReceptorsToIsolate = [4];
                    params.background.whichReceptorsToIgnore = [5 6 7 8];
                    params.background.whichReceptorsToMinimize = [];
                    params.background.whichPoleToUse = 1;
                    params.background.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% LMDirected - low melanopsin background
                    params.modulationDirection = 'LMDirectedLowMel';
                    params.modulationContrast = [0.2 0.2];
                    params.whichReceptorsToIsolate = [1 2];
                    params.whichReceptorsToIgnore = [5 6 7];
                    params.receptorIsolateMode = 'Standard';
                    
                    % Set up the background optimization. We first create the
                    % melanopsin-isolating modulation, which we then use as the background.
                    params.background.modulationDirection = 'MelanopsinDirectedLegacy';
                    params.background.modulationContrast = [0.16];
                    params.background.whichReceptorsToIsolate = [4];
                    params.background.whichReceptorsToIgnore = [5 6 7 8];
                    params.background.whichReceptorsToMinimize = [];
                    params.background.whichPoleToUse = -1;
                    params.background.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                case 4
                    % First, let's generate modulations for the projector
                    % on.
                    params.experiment = 'OLFlickerSensitivity';
                    params.experimentSuffix = 'PupillometryScatterControl';
                    theCalType = 'BoxBLongCableBEyePiece1BeamsplitterProjectorOn';
                    params.calibrationType = theCalType;
                    params.whichReceptorsToMinimize = [];
                    params.CALCULATE_SPLATTER = true;
                    params.maxPowerDiff = 10^(-1.5);
                    params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
                    params.fieldSizeDegrees = 27.5;
                    params.isActive = 1;
                    params.useAmbient = 1;
                    params.REFERENCE_OBSERVER_AGE = 32;
                    params.primaryHeadRoom = 0.02;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% MelanopsinDirectedLegacy - not silencing penumbral cones
                    params.modulationDirection = 'MelanopsinDirectedLegacy';
                    modulationContrast = 0.45;
                    params.modulationContrast = mouldationContrast;
                    params.whichReceptorsToIsolate = [4];
                    params.whichReceptorsToIgnore = [5 6 7 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    
                    % Ask the observer if the contrast is as specified.
                    theAnswer = GetWithDefault(['>>> Was the contrast according to specification, i.e. ' num2str(params.modulationContrast) '? [0 = no, 1 = yes]'], 0);
                    if theAnswer
                        fprintf('*** Great. Saving out cache.\n');
                        OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    else
                        fprintf('*** OK. Let''s reduce it.\n');
                        modulationContrast = GetWithDefault(['>>> Enter lower target contrast (should be below ' num2str(params.modulationContrast) ')?'], params.modulationContrast/2);
                        params.modulationContrast = modulationContrast;
                        [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                        OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    end
                    
                    % Now, use that contrast for generating the modulation
                    % with the projector off, for a contrast match.
                    theCalType = 'BoxBLongCableBEyePiece1BeamsplitterProjectorOff';
                    params.calibrationType = theCalType;
                    params.modulationDirection = 'MelanopsinDirectedLegacy';
                    params.modulationContrast = modulationContrast;
                    params.whichReceptorsToIsolate = [4];
                    params.whichReceptorsToIgnore = [5 6 7 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    % We assume that the contrast drop is more pronounced
                    % in melanopsin, and that the contrast that we just
                    % pegged will be achievable in the S direction.
                    %% SDirected - BoxBLongCableBEyePiece1BeamsplitterProjectorOff
                    theCalType = 'BoxBLongCableBEyePiece1BeamsplitterProjectorOff';
                    params.calibrationType = theCalType;
                    params.modulationDirection = 'SDirected';
                    params.modulationContrast = modulationContrast;
                    params.whichReceptorsToIsolate = [3];
                    params.whichReceptorsToIgnore = [5 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %% SDirected - BoxBLongCableBEyePiece1BeamsplitterProjectorOn
                    theCalType = 'BoxBLongCableBEyePiece1BeamsplitterProjectorOn';
                    params.calibrationType = theCalType;
                    params.modulationDirection = 'SDirected';
                    params.modulationContrast = modulationContrast;
                    params.whichReceptorsToIsolate = [3];
                    params.whichReceptorsToIgnore = [5 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
            end
            
        case 3
            fprintf('Validation.\n');
            fprintf('Splatter maps will be generated if option is selected.\n');
            
            theModulationTypes = {'Standard set (LMDirected, SDirected, MelanopsinDirectedLegacy, MelanopsinDirected, Isochromatic)' ; ...
                'PIPR set (PIPR470, PIPR623)' ; ...
                'Interaction set (LMDirectedHighMel, LMDirectedLowMel)' ; ...
                'S and Mel (Projector ON)' ; ...
                'S and Mel (Projector OFF)'};
            
            %% Prompt for choice on the options
            numAvailOptions = length(theModulationTypes);
            keepPrompting = true;
            while keepPrompting
                % Show the available calibration types.
                fprintf('\n*** Available options ***\n\n');
                for i = 1:length(theModulationTypes)
                    fprintf('%d - %s\n', i, theModulationTypes{i});
                end
                fprintf('\n');
                
                modIndex = GetInput('Select a option', 'number', 1);
                
                % Check the selection.
                if modIndex >= 1 && modIndex <= numAvailOptions
                    keepPrompting = false;
                else
                    fprintf('\n* Invalid selection\n');
                end
            end
            
            % Check if we want to spot-check
            SPOT_CHECK = GetWithDefault('Spot check (shortened) validation?', 1);
            CALCULATE_SPLATTER = GetWithDefault('Calculate splatter for validation (may take a while)?', 0);
            input('*** Press return to pause 5s then continue with the calibration***\n');
            pause(5);
            
            % Convert to logical
            SPOT_CHECK = logical(SPOT_CHECK);
            CALCULATE_SPLATTER = logical(CALCULATE_SPLATTER);
            
            %% Standard parameters
            params.experiment = 'OLFlickerSensitivity';
            params.experimentSuffix = 'Pupillometry';
            theCalType = 'BoxBLongCableAEyePiece2';
            params.calibrationType = theCalType;
            params.whichReceptorsToMinimize = [];
            params.CALCULATE_SPLATTER = CALCULATE_SPLATTER;
            params.maxPowerDiff = 10^(-1.5);
            params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
            params.fieldSizeDegrees = 27.5;
            params.isActive = 1;
            params.useAmbient = 1;
            params.REFERENCE_OBSERVER_AGE = 32;
            params.primaryHeadRoom = 0.02;
            
            switch modIndex
                case 1
                    %% Validate these modulations
                    theDirections = {'LMDirected', 'SDirected', 'MelanopsinDirected', 'MelanopsinDirectedLegacy', 'Isochromatic'};
                    
                    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
                    theOnVector = [1 0 0 0 0];
                    theOffVector = [0 0 0 0 1];
                    WaitSecs(2);
                    for d = 1:length(theDirections)
                        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
                            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', SPOT_CHECK, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', CALCULATE_SPLATTER);
                        close all;
                    end
                    
                    % Save out the validation directories
                    dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
                    for d = 1:length(validationPath)
                        fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
                        fprintf(fid, '%s\n', validationPath{d});
                    end
                case 2
                    %% Validate these modulations
                    theDirections = {'PIPR470', 'PIPR623'};
                    
                    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
                    theOnVector = [1 0];
                    theOffVector = [0 1];
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
                case 3
                    %% Validate these modulations
                    theDirections = {'LMDirectedHighMel', 'LMDirectedLowMel'};
                    
                    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
                    theOnVector = [1 0];
                    theOffVector = [0 1];
                    WaitSecs(2);
                    for d = 1:length(theDirections)
                        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
                            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', SPOT_CHECK, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', CALCULATE_SPLATTER);
                        close all;
                    end
                    
                    % Save out the validation directories
                    dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
                    for d = 1:length(validationPath)
                        fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
                        fprintf(fid, '%s\n', validationPath{d});
                    end
                case 4
                    %% Standard parameters
                    params.experiment = 'OLFlickerSensitivity';
                    params.experimentSuffix = 'Pupillometry';
                    theCalType = 'BoxBLongCableBEyePiece1BeamsplitterProjectorOn';
                    params.calibrationType = theCalType;
                    params.whichReceptorsToMinimize = [];
                    params.CALCULATE_SPLATTER = CALCULATE_SPLATTER;
                    params.maxPowerDiff = 10^(-1.5);
                    params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
                    params.fieldSizeDegrees = 27.5;
                    params.isActive = 1;
                    params.useAmbient = 1;
                    params.REFERENCE_OBSERVER_AGE = 32;
                    params.primaryHeadRoom = 0.02;
                    
                    %% Validate these modulations
                    theDirections = {'SDirected', 'MelanopsinDirectedLegacy'};
                    
                    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
                    theOnVector = [1 0];
                    theOffVector = [0 1];
                    WaitSecs(2);
                    for d = 1:length(theDirections)
                        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
                            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', SPOT_CHECK, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', CALCULATE_SPLATTER);
                        close all;
                    end
                    
                    % Save out the validation directories
                    dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
                    for d = 1:length(validationPath)
                        fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
                        fprintf(fid, '%s\n', validationPath{d});
                    end
                    
                case 5
                    %% Standard parameters
                    params.experiment = 'OLFlickerSensitivity';
                    params.experimentSuffix = 'Pupillometry';
                    theCalType = 'BoxBLongCableBEyePiece1BeamsplitterProjectorOff';
                    params.calibrationType = theCalType;
                    params.whichReceptorsToMinimize = [];
                    params.CALCULATE_SPLATTER = CALCULATE_SPLATTER;
                    params.maxPowerDiff = 10^(-1.5);
                    params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
                    params.fieldSizeDegrees = 27.5;
                    params.isActive = 1;
                    params.useAmbient = 1;
                    params.REFERENCE_OBSERVER_AGE = 32;
                    params.primaryHeadRoom = 0.02;
                    
                    %% Validate these modulations
                    theDirections = {'SDirected', 'MelanopsinDirectedLegacy'};
                    
                    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
                    theOnVector = [1 0];
                    theOffVector = [0 1];
                    WaitSecs(2);
                    for d = 1:length(theDirections)
                        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
                            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', SPOT_CHECK, 'selectedCalType', theCalType, 'CALCULATE_SPLATTER', CALCULATE_SPLATTER);
                        close all;
                    end
                    
                    % Save out the validation directories
                    dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
                    for d = 1:length(validationPath)
                        fid = fopen(fullfile(dataPath, [params.experimentSuffix '-validations.txt']), 'a');
                        fprintf(fid, '%s\n', validationPath{d});
                    end
                    
                    
            end
        case 4
            fprintf('\n*****Shutting down OneLight*****\n');
            ol = OneLight;
            ol.shutdown;
            fprintf('\n*****Exit*****\n');
            keepOuterLoop = false;
        case 5
            fprintf('Generating modulation files.\n');
            fprintf('This process might take some time.\n');
            
            theProtocols = {'Direct flicker modulations (45s, 0.05, 0.5 Hz; LMDirected, SDirected, MelanopsinDirected, MelanopsinDirectedLegacy)' ; ...
                'Distortion product modulations (45s, 0.5 Hz envelope; LMDirected, SDirected, MelanopsinDirected, MelanopsinDirectedLegacy)' ; ...
                'Interaction modulations (45s, 0.1 Hz; LMDirectedHighMel, LMDirectedLowMel)' ; ...
                'PIPR modulations (80s, PIPR470, PIPR623)' ; ...
                'Scatter control modulations (45s, 0.5 Hz MelanopsinDirectedLegacy, 0.05 Hz SDirected)' ; ...
                'Melanopsin brightness modulations (45s, 0.1 Hz, phase-randomized; LMS, Melanopsin, Isochromatic'};
            
            %% Prompt for choice on the options
            numAvailOptions = length(theProtocols);
            keepPrompting = true;
            while keepPrompting
                % Show the available calibration types.
                fprintf('\n*** Available options ***\n\n');
                for i = 1:length(theProtocols)
                    fprintf('%d - %s\n', i, theProtocols{i});
                end
                fprintf('\n');
                
                protIndex = GetInput('Select a option', 'number', 1);
                
                % Check the selection.
                if protIndex >= 1 && protIndex <= numAvailOptions
                    keepPrompting = false;
                else
                    fprintf('\n* Invalid selection\n');
                end
            end
            
            % Ask for the observer ages
            theObserverAges = input('Enter the age of the observers. Pre- and append opening and closing brackets ([20 21 45]): ');
            
            % Go through the protocols
            switch protIndex
                case 1
                    for o = theObserverAges
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirected-45sWindowedFrequencyModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-45sWindowedFrequencyModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-45sWindowedFrequencyModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedLegacy-45sWindowedFrequencyModulation.cfg', o);
                        %OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300s.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-60s.cfg', o);
                    end
                case 2
                    for o = theObserverAges
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Isochromatic-45sWindowedDistortionProductModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirected-45sWindowedDistortionProductModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-45sWindowedDistortionProductModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-45sWindowedDistortionProductModulation.cfg', o);
                        %OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedLegacy-45sWindowedDistortionProductModulation.cfg', o);
                        %OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300s.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-60s.cfg', o);
                    end
                case 3
                    for o = theObserverAges
                        %OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirectedHighMel-45sWindowedFrequencyModulation.cfg', o);
                        %OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirectedLowMel-45sWindowedFrequencyModulation.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-BackgroundHighMel-60s.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-BackgroundLowMel-60s.cfg', o);
                    end
                case 4
                    for o = theObserverAges
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-PIPR470-70sSquarePulse.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-PIPR623-70sSquarePulse.cfg', o)
                        %OLReceptorIsolateMakeModulationStartsStops('Modulation-PIPRBackground-300s.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-PIPRBackground-60s.cfg', o);
                    end
                case 5
                    for o = theObserverAges
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedLegacy-45sWindowedFrequencyModulation_BeamsplitterProjectorOn.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedLegacy-45sWindowedFrequencyModulation_BeamsplitterProjectorOff.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-45sWindowedFrequencyModulation_BeamsplitterProjectorOn.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-45sWindowedFrequencyModulation_BeamsplitterProjectorOff.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300s_BeamsplitterProjectorOn.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300s_BeamsplitterProjectorOff.cfg', o);
                    end
                case 6
                    for o = theObserverAges
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-60s.cfg', o);
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-45sWindowedFrequencyModulation.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-LMSDirected-45sWindowedFrequencyModulation.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Isochromatic-45sWindowedFrequencyModulation.cfg', o)
                    end
            end
        case 6
            fprintf('\n*****Exit*****\n');
            keepOuterLoop = false;
    end
end
