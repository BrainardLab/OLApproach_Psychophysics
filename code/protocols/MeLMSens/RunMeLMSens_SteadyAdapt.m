%% Run MeLMSens protocol

%% Set overall parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
if exist('radiometer','var')
    try radiometer.shutDown
    end
end
clear all; close all; clc;

approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens_SteadyAdapt';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Set output path
participantID = GetWithDefault('>> Enter <strong>participant ID</strong>', 'HERO_xxxx');
participantAge = GetWithDefault('>> Enter <strong>participant age</strong>', 32);
sessionName = GetWithDefault('>> Enter <strong>session number</strong>:', 'session_1');
todayDate = datestr(now, 'yyyy-mm-dd');
protocolDataPath = getpref(protocol,'DataFilesBasePath');
participantDataPath = fullfile(protocolDataPath,participantID);
sessionDataPath = fullfile(participantDataPath,[todayDate '_' sessionName]);
mkdir(sessionDataPath);

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxD';
calibrationType = 'BoxDRandomizedLongCableBEyePiece2_ND01';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~simulate.radiometer
    oneLight.setAll(true);
    commandwindow;
    input('<strong>Focus the radiometer and press enter to pause 3 seconds and start measuring.</strong>\n');
    oneLight.setAll(false);
    pause(3);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Create directions
% Melanopsin isolating direction, directed background
melDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
melDirectionParams.primaryHeadRoom = 0;
melDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3.5);
[MelDirection, MelBackground] = OLDirectionNominalFromParams(melDirectionParams, calibration, 'observerAge', participantAge);
receptors = MelDirection.describe.directionParams.T_receptors;

% LMS flicker direction, on background and background+MelDirection
LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSDirectionParams.primaryHeadRoom = 0;
LMSDirectionParams.modulationContrast = [.05 .05 .05];

%% Run acquisition
% Set directons parameters
background = MelBackground;
direction = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', background, 'observerAge', participantAge);

% Set staircase parameters
staircaseType = 'standard';
contrastStep = 0.005;
maxContrast = 0.05;
minContrast = contrastStep;
contrastLevels = (0:contrastStep:maxContrast);
NTrialsPerStaircase = 40;
NInterleavedStaircases = 3;
stepSizes = [4*contrastStep 2*contrastStep contrastStep];
nUps = [3 2 1];
nDowns = [1 1 1];

%% Initialize staircases
rngSettings = rng('default');
for k = 1:NInterleavedStaircases
    initialGuess = randsample(contrastLevels,1);
    staircases(k) = Staircase(staircaseType,initialGuess, ...
        'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
        'MaxValue', maxContrast, 'MinValue', minContrast);    
end

%% Map response to some action
%  Depending on which key-response was given, map to some action
keyBindings = containers.Map();
keyBindings('Q') = 0;
keyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
keyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];

%% Assemble flicker waveform
samplingFq = 200;
flickerFrequency = 5;
flickerDuration = .5;
flickerWaveform = sinewave(flickerDuration,samplingFq,flickerFrequency);

%% Show adaptation spectrum for adaptation period (preceding any trials)
OLShowDirection(background, oneLight);

%% Run trials
for ntrial = 1:NTrialsPerStaircase % loop over trial numbers
    for k = Shuffle(1:NInterleavedStaircases) % loop over staircases, in randomized order
        %% Assemble modulations
        % Get contrast value
        flickerContrast = getCurrentValue(staircases(k));

        % Assemble flicker primaryWaveform
        direction = direction.ScaleToReceptorContrast(background, receptors, [flickerContrast, flickerContrast, flickerContrast, 0]');

        % Determine which interval (1 or 2) will have flicker
        targetPresent = logical([0 0]);
        targetInterval = randi(length(targetPresent));
        targetPresent(targetInterval) = true;

        % Assemble modulations
        targetModulation = OLAssembleModulation([background, direction],[ones(1,length(flickerWaveform)); flickerWaveform]);
        referenceModulation = OLAssembleModulation(background, ones([1,length(flickerWaveform)]));
        modulations = repmat(referenceModulation,[length(targetPresent),1]);
        modulations(targetPresent) = targetModulation;

        %% Show modulations
        ISI = .5;
        for m = 1:length(modulations)
            mglWaitSecs(ISI);
            Beeper;
            OLFlicker(oneLight, modulations(m).starts, modulations(m).stops, 1/samplingFq,1);
            OLShowDirection(background, oneLight);
        end

        %% Response
        %  Get response from GamePad, but also listen to keyboard
        while true
            responseKey = upper(WaitForKeyChar);
            if any(strcmp(responseKey,keyBindings.keys()))
                break;
            end
        end
        response = keyBindings(responseKey);
        if ischar(response) && response == 'ESCAPE'
            break; % TODO
        end

        %% Correct? Compare response
        correct = all(response == targetPresent);

        %% Update modulation parameters, according to staircase
        staircases(k) = updateForTrial(staircases(k), flickerContrast, correct);
              
    end
end

%% Get threshold estimate
for k = 1:NInterleavedStaircases
    thresholds(k) = [getThresholdEstimate(staircases(k))];
end
    
%% Close radiometer
if exist('radiometer','var') && ~isempty(radiometer)
    radiometer.shutDown()
end

%% Close OneLight
shutdown = input('<strong>Shutdown OneLight? [Y/N]</strong>','s');
if upper(shutdown) == 'Y'
    oneLight.shutdown()
end
oneLight.close();