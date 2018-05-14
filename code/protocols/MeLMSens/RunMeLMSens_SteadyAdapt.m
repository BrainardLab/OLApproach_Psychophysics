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
% Melanopsin directed direction, background
MelDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
MelDirectionParams.primaryHeadRoom = 0;
MelDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3.5);
[MelDirection, MelBackground] = OLDirectionNominalFromParams(MelDirectionParams, calibration, 'observerAge', participantAge);
receptors = MelDirection.describe.directionParams.T_receptors;

% LMS-step directed direction, background
LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSDirectionParams.primaryHeadRoom = 0;
LMSDirectionParams.modulationContrast = OLUnipolarToBipolarContrast([3.5 3.5 3.5]);
[LMSDirection, LMSBackground] = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'observerAge', participantAge);
receptors = LMSDirection.describe.directionParams.T_receptors;

% LMS flicker direction, on background and background+MelDirection
FlickerDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
FlickerDirectionParams.primaryHeadRoom = 0;
FlickerDirectionParams.modulationContrast = [.05 .05 .05];

%% Validations
% TODO

%% Corrections, re-validations
% TODO

%% Setup acquisitions
% Low Mel
acquisitions(1) = Acquisition_FlickerSensitivity_2IFC(...
    MelBackground,...
    OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', MelBackground, 'observerAge', participantAge),...
    receptors,...
    'name',"Mel_low");

% High Mel
acquisitions(2) = Acquisition_FlickerSensitivity_2IFC(...
    MelBackground+MelDirection,...
    OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', MelBackground+MelDirection, 'observerAge', participantAge),...
    receptors,...
    'name',"Mel_high");

% Low LMS
acquisitions(3) = Acquisition_FlickerSensitivity_2IFC(...
    LMSBackground,...
    OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', LMSBackground, 'observerAge', participantAge),...
    receptors,...
    'name',"LMS_low");

% High LMS
acquisitions(4) = Acquisition_FlickerSensitivity_2IFC(...
    LMSBackground+LMSDirection,...
    OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', LMSBackground+LMSDirection, 'observerAge', participantAge),...
    receptors,...
    'name',"LMS_high");

%% Run acquisitions
rngSettings = rng;
acquisitions = Shuffle(acquisitions);

for acquisition = acquisitions
    fprintf('Running acquisition %s...\n',acquisition.name)
    acquisition.initializeStaircases();
    acquisition.runAcquisition(oneLight);

    % Get threshold estimate
    for k = 1:acquisition.NInterleavedStaircases
        acquisition.thresholds(k) = [getThresholdEstimate(acquisition.staircases{k})];
    end
end
    
%% Close radiometer
if exist('radiometer','var') && ~isempty(radiometer)
    radiometer.shutDown()
end

%% Close OneLight
shutdown = input('<strong>Shutdown OneLight? [Y/N]</strong>>> ','s');
if upper(shutdown) == 'Y'
    oneLight.shutdown()
end
oneLight.close();