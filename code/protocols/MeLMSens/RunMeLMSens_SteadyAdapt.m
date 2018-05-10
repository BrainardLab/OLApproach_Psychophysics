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
sessionName = GetWithDefault('>> Enter <strong>session number</strong>:', 'session_1');
todayDate = datestr(now, 'yyyy-mm-dd');
protocolDataPath = getpref(protocol,'DataFilesBasePath');
participantDataPath = fullfile(protocolDataPath,participantID);
sessionDataPath = fullfile(participantDataPath,[todayDate '_' sessionName]);
mkdir(sessionDataPath);

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxBRandomizedLongCableBEyePiece2_ND01';
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

%% Setup acquisition
% Set directons parameters
acquisition = Acquisition_FlickerSensitivity_2IFC(...
    OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', MelBackground, 'observerAge', participantAge),...
    MelBackground,...
    receptors);

%% Run acquisition
acquisition.initializeStaircases();
acquisition.runAcquisition(oneLight);

% Get threshold estimate
for k = 1:acquisition.NInterleavedStaircases
    thresholds(k) = [getThresholdEstimate(acquisition.staircases{k})];
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