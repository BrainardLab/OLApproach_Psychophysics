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
protocol = 'MeLMSens';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Set output path
participantID = GetWithDefault('>> Enter <strong>participant ID</strong>', 'HERO_xxxx');
participantAge = GetWithDefault('>> Enter <strong>participant age</strong>', 32);
sessionName = GetWithDefault('>> Enter <strong>session name</strong>:', 'session_1');
todayDate = datestr(now, 'yyyymmdd');
protocolDataPath = getpref(protocol,'ProtocolDataRawPath');
participantDataPath = fullfile(protocolDataPath,participantID);
sessionDataPath = fullfile(participantDataPath,[todayDate '_' sessionName]);

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxBRandomizedLongCableBEyePiece3Beamsplitter';
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~simulate.radiometer
    oneLight.setAll(true);
    commandwindow;
    input('<strong>Turn on radiometer and connect to USB; press any key to connect to radiometer</strong>\n');
    oneLight.setAll(false);
    pause(3);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Get directions
directions = MakeNominalMeLMSens_SteadyAdapt(calibration,'observerAge',participantAge);

%% Validations
receptors = directions('MelStep').describe.directionParams.T_receptors;
input('<strong>Place eyepiece in radiometer, and press any key to start measuring.</strong>\n'); pause(5);
validations = containers.Map();
validations('Mel_lowhigh') = OLValidateDirection(directions('MelStep'), directions('Mel_low'), oneLight, radiometer, 'receptors', receptors);
validations('LMS_lowhigh')  = OLValidateDirection(directions('LMSStep'), directions('LMS_low'), oneLight, radiometer, 'receptors', receptors);
validations('Flicker_Mel_low') = OLValidateDirection(directions('FlickerDirection_Mel_low'), directions('Mel_low'), oneLight, radiometer, 'receptors', receptors);
validations('Flicker_Mel_high') = OLValidateDirection(directions('FlickerDirection_Mel_high'), directions('Mel_high'), oneLight, radiometer, 'receptors', receptors);
validations('Flicker_LMS_low') = OLValidateDirection(directions('FlickerDirection_LMS_low'), directions('LMS_low'), oneLight, radiometer, 'receptors', receptors);
validations('Flicker_LMS_high') = OLValidateDirection(directions('FlickerDirection_LMS_high'), directions('LMS_high'), oneLight, radiometer, 'receptors', receptors);

%% Corrections, re-validations
% TODO

%% Setup acquisitions
% Low Mel
acquisitions(1) = Acquisition_FlickerSensitivity_2IFC(...
    directions('Mel_low'),...
    directions('FlickerDirection_Mel_low'),...
    receptors,...
    'name',"Mel_low");

% High Mel
acquisitions(2) = Acquisition_FlickerSensitivity_2IFC(...
    directions('Mel_high'),...
    directions('FlickerDirection_Mel_high'),...
    receptors,...
    'name',"Mel_high");

% Low LMS
acquisitions(3) = Acquisition_FlickerSensitivity_2IFC(...
    directions('LMS_low'),...
    directions('FlickerDirection_LMS_low'),...
    receptors,...
    'name',"LMS_low");

% High LMS
acquisitions(4) = Acquisition_FlickerSensitivity_2IFC(...
    directions('LMS_high'),...
    directions('FlickerDirection_LMS_high'),...
    receptors,...
    'name',"LMS_high");

% Combine
rngSettings = rng('shuffle');
acquisitions = Shuffle(acquisitions);

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];

gamePad = GamePad();
trialResponseSys = responseSystem(trialKeyBindings,gamePad);

%% Run
projectorWindow = makeProjectorSpot('Fullscreen',~simulate.projector); % make projector spot window object
toggleProjectorSpot(projectorWindow,true); % toggle on
mkdir(sessionDataPath);
for acquisition = acquisitions
    fprintf('Running acquisition %s...\n',acquisition.name)
    acquisition.initializeStaircases();
    acquisition.runAcquisition(oneLight, trialResponseSys);
    fprintf('Acquisition complete.\n'); Speak('Acquisition complete.',[],230);
    input('<strong>Place eyepiece in radiometer, and press any key to start measuring.</strong>\n'); pause(3);
    acquisition.postAcquisition(oneLight, radiometer);
    
    % Save acquisition
    filename = sprintf('data-%s-%s-%s.mat',participantID,sessionName,acquisition.name);
    if isfile(fullfile(sessionDataPath,filename))
        prevAcq = load(fullfile(sessionDataPath,filename));
        acquisition = [prevAcq.acquisition acquisition];
    end
    save(fullfile(sessionDataPath,filename),'acquisition');
end

%% Close radiometer
if exist('radiometer','var') && ~isempty(radiometer)
    radiometer.shutDown();
end
clear radiometer;

%% Close projectorWindow
projectorWindow.close()

%% Close GamePad
gamePad.shutDown()

%% Close OneLight
shutdown = input('<strong>Shutdown OneLight? [Y/N]</strong>>> ','s');
if upper(shutdown) == 'Y'
    oneLight.shutdown();
end
oneLight.close()