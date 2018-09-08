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
mkdir(sessionDataPath);

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxBRandomizedShortCableAEyePiece3Beamsplitter';
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

%% Get projectorSpot
oneLight.setAll(true);
pSpot = projectorSpotMeLMSens_SteadyAdapt(simulate.projector);
pSpot.show();

%% Update OLCalibration with pSpot
calibration = UpdateOLCalibrationWithProjectorSpot(calibration, pSpot, oneLight, radiometer);

%% Get directions
directions = MakeNominalMeLMSens_SteadyAdapt(calibration,'observerAge',32);
receptors = directions('MelStep').describe.directionParams.T_receptors;
save(fullfile(sessionDataPath,materialsFilename),...
                'directions','receptors','-append');

%% Validate directions pre-correction
validationsPre = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);
save(fullfile(sessionDataPath,materialsFilename),'directions','validationsPre','-append');
                                            
%% Correct directions
correctMeLMSens_SteadyAdapt(directions,oneLight,calibration,radiometer,'receptors',receptors);

%% Validate directions post-correction
validationsPost = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);
save(fullfile(sessionDataPath,materialsFilename),'directions','validationsPost','-append');

%% Setup acquisitions
acquisitions = makeAcquisitionsMeLMSens_SteadyAdapt(directions, receptors,...
                'adaptationDuration',minutes(5),...
                'NTrialsPerStaircase',40);
save(fullfile(sessionDataPath,materialsFilename),'acquisitions','-append');            

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];

if ~simulate.gamepad
    gamePad = GamePad();
    trialKeyBindings('GP:B') = 'abort';
    trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
    trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];    
else
    gamePad = [];
end
trialResponseSys = responseSystem(trialKeyBindings,gamePad);

%% Run
pSpot.show();
mkdir(sessionDataPath);
for acquisition = acquisitions
    fprintf('Running acquisition %s...\n',acquisition.name)
    acquisition.initializeStaircases();
    acquisition.runAcquisition(oneLight, trialResponseSys);
    fprintf('Acquisition complete.\n'); Speak('Acquisition complete.',[],230);
    
    % Save acquisition
    dataFilename = sprintf('data-%s-%s-%s.mat',participantID,sessionName,acquisition.name);
    if isfile(fullfile(sessionDataPath,dataFilename))
        prevAcq = load(fullfile(sessionDataPath,dataFilename));
        acquisition = [prevAcq.acquisition acquisition];
    end
    save(fullfile(sessionDataPath,dataFilename),'acquisition');
    save(fullfile(sessionDataPath,materialsFilename),'acquisitions','-append');    
end

%% Validate post acquisitions
input('<strong>Place eyepiece in radiometer, and press any key to start measuring.</strong>\n'); pause(3);
for acquisition = acquisitions
    % Run post acquisition routine
    acquisition.postAcquisition(oneLight, radiometer);    

    % Save acquisition
    dataFilename = sprintf('data-%s-%s-%s.mat',participantID,sessionName,acquisition.name);
    if isfile(fullfile(sessionDataPath,dataFilename))
        prevAcq = load(fullfile(sessionDataPath,dataFilename));
        acquisition = [prevAcq.acquisition acquisition];
    end
    save(fullfile(sessionDataPath,dataFilename),'acquisition');
    save(fullfile(sessionDataPath,materialsFilename),'acquisitions','-append');        
end

%% Close radiometer
if exist('radiometer','var') && ~isempty(radiometer)
    radiometer.shutDown();
end
clear radiometer;

%% Close projectorWindow
pSpot.close()

%% Close GamePad
gamePad.shutDown()

%% Close OneLight
shutdown = input('<strong>Shutdown OneLight? [Y/N]</strong>>> ','s');
if upper(shutdown) == 'Y'
    oneLight.shutdown();
end
oneLight.close()