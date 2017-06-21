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
            
            theModulationTypes = {'Melanopsin-cone interaction set (L+M, Melanopsin, L+M+Melanopsin)'};
            
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
                    params.experimentSuffix = 'MR';
                    theCalType = 'OLBoxBLongCableAEyePiece2';
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
                    %% LMDirected
                    params.modulationDirection = 'LMDirected';
                    params.modulationContrast = [0.5 0.5];
                    params.whichReceptorsToIsolate = [1 2];
                    params.whichReceptorsToIgnore = [5 6 7];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% MelanopsinDirectedLegacy - not silencing penumbral cones
                    params.modulationDirection = 'MelanopsinDirectedLegacy';
                    params.modulationContrast = [0.5];
                    params.whichReceptorsToIsolate = [4];
                    params.whichReceptorsToIgnore = [5 6 7 8];
                    params.receptorIsolateMode = 'Standard';
                    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
                    [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
                    OLReceptorIsolateSaveCache(cacheData, olCache, params);
                    
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %% Isochromatic
%                     params.modulationDirection = 'Isochromatic';
%                     params.modulationContrast = [0.45];
%                     params.whichReceptorsToIsolate = [];
%                     params.whichReceptorsToIgnore = [];
%                     params.receptorIsolateMode = 'Standard';
%                     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%                     [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
%                     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%                     
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %% LMMelDirected
%                     params.modulationDirection = 'LMMelDirected';
%                     params.modulationContrast = [0.45 0.45 0.45];
%                     params.whichReceptorsToIsolate = [1 2 4];
%                     params.whichReceptorsToIgnore = [5 6 7];
%                     params.receptorIsolateMode = 'Standard';
%                     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%                     [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
%                     OLReceptorIsolateSaveCache(cacheData, olCache, params);
%                     
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %% LMMelDirected
%                     params.modulationDirection = 'LMSDirected';
%                     params.modulationContrast = [0.45 0.45 0.45];
%                     params.whichReceptorsToIsolate = [1 2 3];
%                     params.whichReceptorsToIgnore = [5 6 7 8];
%                     params.receptorIsolateMode = 'Standard';
%                     params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
%                     [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimaries(params, true);
%                     OLReceptorIsolateSaveCache(cacheData, olCache, params);
            end
            
        case 3
            fprintf('Validation.\n');
            fprintf('Splatter maps will be generated if option is selected.\n');
            
            theModulationTypes = {'Melanopsin-cone interaction set (L+M, Melanopsin, L+M+Melanopsin)'};
            
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
            params.experimentSuffix = 'MR';
            theCalType = 'OLBoxALongCableCEyePiece1';
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
                    theDirections = {'MelanopsinDirectedLegacy', 'LMDirected' 'LMSDirected'};
                    
                    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
                    theOnVector = [1 0 0];
                    theOffVector = [0 0 1];
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
            
            theProtocols = {'Superimposed L+M flicker on different backgrounds' , 'Wade & Wandell / Horiguchi et al. stimuli'};
            
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
                   
                    for o = [27]
                        
                        
                        %% Let's figure what contrast we can have
                        %OLMakeInteractionModulation(cal, 'LMDirected', [], [], o), [];
                        %OLMakeInteractionModulation(cal, 'LMDirectedScaled', [], [], o, []);
                        %OLMakeInteractionModulation(cal, 'MelanopsinDirectedLegacy', [], [], o, []);
                        %OLMakeInteractionModulation(cal, 'LMMelDirected', [], [], o, []);
                        
                        %% With flicker superimposed
                        %flickerContrast = 1/3;
                        %bgContrast = 2/3;
                        %OLMakeInteractionModulation(cal, 'LMDirected', bgContrast, flickerContrast, o, []);
                        %OLMakeInteractionModulation(cal, 'MelanopsinDirectedLegacy', bgContrast, flickerContrast, o, []);
                        %OLMakeInteractionModulation(cal, 'LMDirectedScaled', bgContrast, flickerContrast, o, []);
                        %OLMakeInteractionModulation(cal, 'LMMelDirected', bgContrast, flickerContrast, o, []);
                        
                        %% With no flicker
                        %OLMakeInteractionModulation(cal, 'LMDirected', bgContrast, 0, o, []);
                        %OLMakeInteractionModulation(cal, 'MelanopsinDirectedLegacy', bgContrast, 0, o, []);
                        %OLMakeInteractionModulation(cal, 'LMDirectedScaled', bgContrast, 0, o, []);
                        %OLMakeInteractionModulation(cal, 'LMMelDirected', bgContrast, 0, o, []);
                    end
                case 2
                    cal = OLGetCalibrationStructure;
                    % Wade & Wandell interaction
                    flickerContrast = 1/3;
                    bgContrast = 2/3;
                    for o = [27]
                        %OLMakeInteractionModulationPulses(cal, 'LMDirected', 'ramp', bgContrast, flickerContrast, 10, 1/36, o)
                        %OLMakeInteractionModulationPulses(cal, 'MelanopsinDirectedLegacy', 'ramp', bgContrast, flickerContrast, 10, 1/36, o);
                        
                        % Horiguchi et al. luxotonic
                         cal = OLGetCalibrationStructure;
                        OLMakeIsochromaticLocalizer(cal, 'Isochromatic', 1, o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-Isochromatic-312sSquareWaveModulation.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-LMSDirected-312sSquareWaveModulation.cfg', o)
                        OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedLegacy-312sSquareWaveModulation.cfg', o)
                    end
            end
        case 6
            fprintf('\n*****Exit*****\n');
            keepOuterLoop = false;
    end
end
