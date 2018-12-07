%% Run MeLMSens protocol

%% Set overall parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
clear all; close all; clc;
approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens_SteadyAdapt';
import(sprintf('%s.*',protocol));
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
materialsFilename = sprintf('materials-%s-%s.mat',participantID,sessionName);

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxBRandomizedShortCableAEyePiece3Beamsplitter';
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');
save(fullfile(sessionDataPath, materialsFilename),...
                'calibration','-v7.3');

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

%% Get temperatureProbe
temperatureProbe = LJTemperatureProbe();
temperatureProbe.open();

%% Get projectorSpot
oneLight.setAll(true);
pSpot = projectorSpot(simulate.projector);
pSpot.show();

%% Update OLCalibration with pSpot
pSpotMeasurements = projectorSpot.measure(pSpot,oneLight,radiometer);
[calibration, pSpotSPD, pSpotLum] = projectorSpot.UpdateOLCalibrationWithProjectorSpot(calibration, pSpotMeasurements);
save(fullfile(sessionDataPath,materialsFilename),...
    'calibration','pSpotSPD','pSpotLum','pSpotMeasurements','-append','-v7.3');
            
%% Get directions
directions = makeNominalDirections(calibration,'observerAge',32);
receptors = directions('MelStep').describe.directionParams.T_receptors;
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','receptors','-append','-v7.3');

%% Validate directions pre-correction
pSpot.show();
validationsPre = validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','validationsPre','-append','-v7.3');
                                            
%% Correct directions
pSpot.show();
corrections = correctDirections(directions,oneLight,calibration,radiometer,...
                            receptors,...
                            'smoothness',.001,...
                            'temperatureProbe',temperatureProbe);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','corrections','-append','-v7.3');

%% Validate directions post-correction
pSpot.show();
validationsPostCorrection = validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','validationsPostCorrection','-append','-v7.3');

%% Setup acquisitions
acquisitions = makeAcquisitions(directions, receptors,...
                'adaptationDuration',minutes(5),...
                'NTrialsPerStaircase',40);
save(fullfile(sessionDataPath,materialsFilename),...
    'acquisitions','-append','-v7.3');            

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('GP:UPPERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:UPPERRIGHTTRIGGER') = [0 1];  
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

%% Adjust projectorSpot
projectorSpot.adjust(pSpot,gamePad);

%% Run
pSpot.show();
for acquisition = acquisitions
    fprintf('Running acquisition...\n')
    acquisition.initializeStaircases();
    acquisition.runAcquisition(oneLight, trialResponseSys);
    fprintf('Acquisition complete.\n'); Speak('Acquisition complete.',[],230);
    
    % Save acquisition
    dataFilename = sprintf('data-%s-%s-%s.mat',participantID,sessionName,acquisition.name);
    if isfile(fullfile(sessionDataPath,dataFilename))
        prevAcq = load(fullfile(sessionDataPath,dataFilename));
        acquisition = [prevAcq.acquisition acquisition];
    end
    save(fullfile(sessionDataPath,dataFilename),'acquisition','-v7.3');
end

%% Validate post acquisitions
input('<strong>Place eyepiece in radiometer, and press any key to start measuring.</strong>\n'); pause(3);
pSpot.show();
for acquisition = acquisitions
    fprintf('Running post-acquisition routine for %s...',acquisition.name);
    % Run post acquisition routine
    acquisition.postAcquisition(oneLight, radiometer);    

    % Save acquisition
    dataFilename = sprintf('data-%s-%s-%s.mat',participantID,sessionName,acquisition.name);
    save(fullfile(sessionDataPath,dataFilename),'acquisition','-v7.3');
    fprintf('done.\n');
end

%% Validate directions
pSpot.show();
validationsPostSession = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','validationsPostSession',...
    '-append','-v7.3');

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