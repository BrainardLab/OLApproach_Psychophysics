%% Demo of modulations in the MeLMSens protocol
%
% This demo displays 3 modulations that are used in the MeLMSens
% protocol: 
%   - LMS flicker on a steady background, at 500ms into the trial 
%   - LMS flicker on a 4s, 300% contrast melanopsin pulse, at 500ms into 
%     the trial (when melanopsin pulse reaches max after cosine window)
%   - LMS flicker on a 4s, 300% contrast melanopsin pulse, at 1500ms into 
%     the trial (1s after melanopsin pulse reaches max)
%
% All modulations assume a 32 year-old observer. Contrast, duration and
% frequency of LMS flicker can be adjust before modulations are shown.
%
%% Set overall parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
if exist('radiometer','var')
    try radiometer.shutDown
    end
end
clear all; close all; clc;

approach = 'OLApproach_Psychophysics';
protocol = 'Demo';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Get calibration
% Specify which calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
calibrationType = 'BoxDRandomizedLongCableBEyePiece2_ND01';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Create directions
participantAge = 32;

% Melanopsin isolating direction, background
melDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
melDirectionParams.primaryHeadRoom = 0;
melDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3);
[MelDirection, background] = OLDirectionNominalFromParams(melDirectionParams, calibration, 'observerAge', participantAge);

% LMS flicker, on background and on background+MelDirection
LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSDirectionParams.primaryHeadRoom = 0;
LMSDirectionParams.modulationContrast = [.05 .05 .05];
LMSDirection(4) = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', background+MelDirection, 'observerAge', participantAge);
LMSDirection(1) = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', background, 'observerAge', participantAge);

% Retrieve the receptors
receptors = LMSDirection(4).describe.directionParams.T_receptors;

%% Set modulation parameters 
% Define constant params:
pulseDuration = 4;      % s
flickerParams.flickerDuration = GetWithDefault('>> Enter <strong>LMS flicker duration</strong>',.5); % s
flickerParams.flickerFrequency = GetWithDefault('>> Enter <strong>LMS flicker frequency</strong>',5);  % Hz
flickerParams.flickerContrast = GetWithDefault('>> Enter <strong>LMS flicker contrast</strong>',.05);

%% Assemble modulations
modulation(1) = AssembleModulation_MeLMS(background,MelDirection,LMSDirection(1),receptors,2,0,0,flickerParams);
modulation(2) = AssembleModulation_MeLMS(background,MelDirection,LMSDirection(4),receptors,pulseDuration,3,0,flickerParams);
modulation(3) = AssembleModulation_MeLMS(background,MelDirection,LMSDirection(4),receptors,pulseDuration,3,1,flickerParams);
[backgroundStarts, backgroundStops] = OLPrimaryToStartsStops(background.differentialPrimaryValues, background.calibration);

%% Display modulations
oneLight = OneLight('simulate',simulate.oneLight);
for i = 1:numel(modulation)
    % Set to background, for adaptation
    oneLight.setMirrors(backgroundStarts, backgroundStops);
    WaitForKeyPress;

    % Display stimulus
    Beeper;
    OLFlicker(oneLight,modulation(i).starts,modulation(i).stops,modulation(i).timestep, 1);
    oneLight.setMirrors(backgroundStarts, backgroundStops);
end