%% Run MeLMSens protocol

%% Set the parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
if exist('radiometer','var')
    try radiometer.shutDown;
    catch
    end
end
clear all; close all; clc;

approach = 'OLApproach_Psychophysics';
protocol = 'RunMeLMSens';
observerAge = 32;
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

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
% Melanopsin isolating direction
melDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
melDirectionParams.primaryHeadRoom = 0;
melDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3);
[MelDirection, background] = OLDirectionNominalFromParams(melDirectionParams, calibration, 'observerAge', observerAge);
LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSDirectionParams.primaryHeadRoom = 0;
LMSDirection = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', background+MelDirection, 'observerAge', observerAge);

% Desired contrasts
receptors = LMSDirection.describe.directionParams.T_receptors;
[nominalMelPulseContrast, nomMelExcitations] = ToDesiredReceptorContrast(MelDirection,background, receptors);
[nominalMaxLMSFlickerContrast, nomLMSExcitations] = ToDesiredReceptorContrast(LMSDirection, background+MelDirection, receptors);

%% Validate the directions
% Pre-correction validation
OLValidateDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(MelDirection, background, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction');
OLValidateDirection(LMSDirection, background+MelDirection, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction');

%% Correct (and re-validate)
OLCorrectDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer);
OLCorrectDirection(MelDirection, background, oneLight, radiometer);
OLCorrectDirection(LMSDirection, background+MelDirection, oneLight, radiometer);

% Post-correction validation
OLValidateDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer, 'receptors', receptors, 'label','post-correction');
OLValidateDirection(MelDirection, background, oneLight, radiometer, 'receptors', receptors, 'label','post-correction');
OLValidateDirection(LMSDirection, background+MelDirection, oneLight, radiometer, 'receptors', receptors, 'label','post-correction');

%% Set initial modulation params
pulseDuration = 3;
pulseContrast = 3;
flickerDuration = .250;
flickerFrequency = 25;
flickerLag = 0;
flickerContrast = .025;

modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection,...
        pulseDuration, pulseContrast, flickerDuration, flickerLag, flickerFrequency, flickerContrast, receptors);
[backgroundStarts, backgroundStops] = OLPrimaryToStartsStops(background.differentialPrimaryValues, background.calibration);

%% Unhook radiometer
% We don't need the radiometer for now, so allow the user to unhook the
% eyepiece from the radiometer, and set it up for viewing.
if ~simulate.radiometer
    oneLight.setAll(false);
    commandwindow;
    input(sprintf('<strong>Unhook the eyepiece from the radiometer and set up for viewing. Press enter to continue</strong>\n'));
end
clear radiometer;

%% Run trial loop
% Get gamepad
oneLight.setMirrors(backgroundStarts, backgroundStops);
gpad = GamePad;
WaitForKeyPress;

accept = false;
while ~accept
    % Set OneLight to background
    oneLight.setMirrors(backgroundStarts, backgroundStops);

    % Assemble stimulus for this trial
    modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection,...
        pulseDuration, pulseContrast, flickerDuration, flickerLag, flickerContrast, receptors);

    % Display stimulus
    OLFlicker(oneLight,modulation.starts,modulation.stops,modulation.timestep, 1);
    oneLight.setMirrors(backgroundStarts, backgroundStops);
    
    % Wait for gamepad
    WaitForKeyPress;
    key = gpad.getKeyEvent;

    % Update params
    switch key.charCode
        case 'GP:LowerRightTrigger'
            flickerContrast = flickerContrast + .005;
        case 'GP:LowerLeftTrigger'
            flickerContrast = flickerContrast - .005;
        case 'GP:A'
            accept = true;
    end
end

%% Validate scaled directions post acquisition
scaledMel = ScaleToReceptorContrast(MelDirection, background, receptors, [0 0 0 pulseContrast]');
scaledLMS = ScaleToReceptorContrast(LMSDirection, background+scaledMel, receptors, [flickerContrast flickerContrast flickerContrast 0]');
backgroundValidation = OLValidateDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
scaledMelValidation = OLValidateDirection(scaledMel, background, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction');
LMSValidation = OLValidateDirection(scaledLMS, background+scaledMel, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction');

%% Close radiometer
if exist('radiometer','var') && ~isempty(radiometer)
    radiometer.shutDown()
end