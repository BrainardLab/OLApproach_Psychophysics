%% Demo protocol in the Psychophysics approach
% This script demonstrates the workflow of running a protocol in the
% psychophysics approach.

%% Set the parameter structure here
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
clear all; close all; clc;
protocolParams.approach = 'OLApproach_Psychophysics';
protocolParams.protocol = 'Demo';
protocolParams.observerAge = 32;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.radiometer = true;
radiometerPauseDuration = 0;

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
protocolParams.boxName = 'BoxC';  
protocolParams.calibrationType = 'BoxCRandomizedLongCableBEyePiece2_ND01';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',protocolParams.calibrationType,'CalibrationDate','latest');

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',protocolParams.simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~protocolParams.simulate.radiometer
    oneLight.setAll(true);
    commandwindow;
    fprintf('Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
    input('');
    oneLight.setAll(false);
    pause(radiometerPauseDuration);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Create the melanopsin direction with maximal bipolar contrast
% There are several ways to construct a direction. Here, we demonstrate
% getting a set of parameters from the directions dictionary, adjusting
% some of those parameters, and then generating the direction.
directionParams = OLDirectionParamsFromName('MaxMel_bipolar_275_80_667');
directionParams.primaryHeadRoom = .01;
directionNominalStruct = OLDirectionNominalStructFromParams(directionParams, calibration, 'observerAge', protocolParams.observerAge);

%% Correct and validate the direction
% The nominal primary values often do not generate the spectral power
% distributions that we expect. We iteratively correct the primary values
% to get closer to the desired SPDs, and then validate that these primary
% values produce a direction that we can live with. 
directionCorrectedStruct = OLCorrectDirection(directionNominalStruct, calibration, oneLight, radiometer);
SPDs = OLValidateDirection(directionCorrectedStruct, calibration, oneLight, radiometer);

%% Create the temporal waveform
% Just like with directions, temporal waveforms can be constructed in
% several ways. Again, we demonstrate here getting a set of parameters from
% a dictionary, adjusting a parameter, and then constructing the waveform.
waveformParams = OLWaveformParamsFromName('MaxContrast3sSinusoid');
waveformParams.stimulusDuration = 5;
[waveform, timestep] = OLWaveformFromParams(waveformParams);

%% Assemble the modulation
% The direction information, and the temporal waveform, are combined into a
% a modulation. This modulation is also converted to starts/stops. All this
% data is stroed in a structure 'modulation'.
modulation = OLAssembleModulation(directionCorrectedStruct,waveform,calibration);

%% Package trial for DemoEngine
% The Psychophysics engine (or at least this demo version) expects
% information to be packaged in a certain way, so thats what we do here.
trialList = struct([]);
trial.adaptTime = 1;
trial.repeats = 1;
trial.directionName = 'MaxMel_bipolar_275_80_667';
trial.modulationStarts = modulation.starts;
trial.modulationStops = modulation.stops;
[trial.backgroundStarts, trial.backgroundStops] = OLPrimaryToStartsStops(directionCorrectedStruct.backgroundPrimary, calibration); 
trial.timestep = timestep;
trialList = [trialList, trial];

%% Close radiometer
% We don't need the radiometer for now, so let's make sure we close it
% properly. This allows the user to unhook the eyepiece from the
% radiometer, and set it up for viewing.
if ~protocolParams.simulate.radiometer
    shutDown(radiometer);
    oneLight.setAll(false);
    commandwindow;
    fprintf('Unhook the eyepiece from the radiometer and set up for viewing. Press enter to pause %d seconds and start experiment.\n', radiometerPauseDuration);
    input('');
    pause(radiometerPauseDuration);
end
clear radiometer;

%% Run demo trial
% Call the DemoEngine to execute our trials
DemoEngine(trialList,oneLight,'speakRate',getpref(protocolParams.approach, 'SpeakRateDefault'));

%% Validate direction corrected primaries post experiment
% We often want to validate our directions after the experiment as well, so
% that we know that we had the correct SPDs throughout.

% Setup radiometer
if ~protocolParams.simulate.radiometer
    radiometerPauseDuration = 0;
    oneLight.setAll(true);
    commandwindow;
    fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
    input('');
    oneLight.setAll(false);
    pause(radiometerPauseDuration);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

% Validate direction corrected primaries post experiment
SPDs = OLValidateDirection(directionCorrectedStruct, calibration, oneLight, radiometer);

% Close radiometer
if ~protocolParams.simulate.radiometer
    shutDown(radiometer);
end
clear radiometer;