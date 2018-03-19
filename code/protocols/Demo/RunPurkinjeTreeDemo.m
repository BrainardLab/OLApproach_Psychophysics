%% Demonstration of Purkinje tree visualization
% This script demonstrates a modulation that selectively stimulates the
% penumbral cones, thus visualizing the Purkinje tree.
%
% For a more detailed explanation of running a protocol in the
% PsychophysicsApproach, see RunDemo

%% Set the parameter structure here
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
clear all; close all; clc;
protocolParams.approach = 'OLApproach_Psychophysics';
protocolParams.protocol = 'Demo'; % all demos can be filed under the same protocol
protocolParams.simulate.oneLight = false;
protocolParams.simulate.radiometer = false;
radiometerPauseDuration = 0;

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
protocolParams.boxName = 'BoxD';
protocolParams.calibrationType = 'BoxDRandomizedLongCableBEyePiece2_ND01';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',protocolParams.calibrationType,'CalibrationDate','latest');
S = calibration.describe.S;
B_primary = calibration.computed.pr650M;
ambientSpd = calibration.computed.pr650MeanDark;
primaryHeadRoom = .02;
maxPowerDiff = 10^-1.5;

%% Generate penumbral cone isolating direction
% Define observer params
protocolParams.observerAge = 32;
protocolParams.fieldSize = 27.5;
protocolParams.pupilDiameter = 4.7;

% Get photoreceptors
receptors = SSTReceptorHuman('verbosity','low',...
    'obsAgeInYrs',protocolParams.observerAge,...
    'obsPupilDiameter',protocolParams.pupilDiameter,...
    'fieldSizeDeg',protocolParams.fieldSize,...
    'doPenumbralConesTrueFalse',true);

% Target penumbral L, M and S, silence open field and melanopsin, ignore
% rods (since we're at photopic lightlevels) and melanopsin
targetReceptors = {[6 7 8]};
silenceReceptors = {[1 2 3]};
ignoreReceptors = {[4 5]};

% Generate background
initialPrimary = repmat(.5,size(B_primary,2),1);
optimizedBackgroundPrimaries = ReceptorIsolateOptimBackgroundMulti(receptors.T.T_energyNormalized, targetReceptors, ...
    ignoreReceptors,silenceReceptors,B_primary,initialPrimary,initialPrimary,[],primaryHeadRoom,maxPowerDiff,...
    {[2/3 2/3 2/3]},ambientSpd,[0],[0],false);
backgroundPrimary = optimizedBackgroundPrimaries{1};

% Generate direction
directionPrimary = ReceptorIsolate(receptors.T.T_energyNormalized,targetReceptors{1},ignoreReceptors{1},...
    [],B_primary, backgroundPrimary, backgroundPrimary, [], primaryHeadRoom,...
    maxPowerDiff, [], ambientSpd);

% Create unipolar direction, and unipolar background.
differential = directionPrimary - backgroundPrimary; % determine initial bipolar differential
backgroundPrimary = backgroundPrimary - differential; % set new background (background - bipolar differential)
differential = directionPrimary - backgroundPrimary; % determine unipolar differential (direction - new background)
background = OLDirection_unipolar(backgroundPrimary,calibration);
direction = OLDirection_unipolar(differential,calibration);

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',protocolParams.simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~protocolParams.simulate.radiometer
    oneLight.setAll(true);
    commandwindow;
    input(sprintf('<strong>Focus the radiometer and press enter to pause %d seconds and start measuring.</strong>\n', radiometerPauseDuration));
    oneLight.setAll(false);
    pause(radiometerPauseDuration);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Validate pre correction
OLValidateDirection(direction, background, oneLight, radiometer,'receptors',receptors);

%% Correct
OLCorrectDirection([background, direction],[OLDirection_unipolar.Null(calibration), background], oneLight, radiometer, 'iterativeSearch',true);

%% Validate
OLValidateDirection(direction, background, oneLight, radiometer,'receptors',receptors);

%% Close radiometer
% We don't need the radiometer for now, so let's make sure we close it
% properly. This allows the user to unhook the eyepiece from the
% radiometer, and set it up for viewing.
if ~protocolParams.simulate.radiometer
    shutDown(radiometer);
    oneLight.setAll(false);
    commandwindow;
    input(sprintf('<strong>Unhook the eyepiece from the radiometer and set up for viewing. Press enter to pause %d seconds and start experiment.</strong>\n', radiometerPauseDuration));
    pause(radiometerPauseDuration);
end
clear radiometer;

%% Generate waveform, assemble modulation
waveformParams = OLWaveformParamsFromName('MaxContrastSquarewave');
waveformParams.frequency = 16;
waveformParams.stimulusDuration = 10;
[waveform, timestep] = OLWaveformFromParams(waveformParams);
modulationStruct = OLAssembleModulation([background, direction],[ones(1,length(waveform)); waveform]);

%% Package trial for DemoEngine
% The Psychophysics engine (or at least this demo version) expects
% information to be packaged in a certain way, so thats what we do here.
trialList = struct([]);

trial.name = 'Penubmral_squarewave_10s';
trial.modulationStarts = modulationStruct.starts;
trial.modulationStops = modulationStruct.stops;
[trial.backgroundStarts, trial.backgroundStops] = OLPrimaryToStartsStops(background.differentialPrimaryValues, calibration);
trial.timestep = timestep;
trial.adaptTime = 1;
trial.repeats = 1;

trialList = [trialList, trial];

%% Run demo trial
% Call the DemoEngine to execute our trials
DemoEngine(trialList,oneLight,'speakRate',getpref(protocolParams.approach, 'SpeakRateDefault'));

%% Close OneLight
shutdown = input('<strong>Shutdown OneLight? [Y/N]</strong>','s');
if upper(shutdown) == 'Y'
    oneLight.shutdown()
end
clear oneLight