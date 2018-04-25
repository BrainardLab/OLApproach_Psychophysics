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
calibrationType = 'BoxBRandomizedLongCableBEyePiece2_ND01';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Create directions
observerAge = GetWithDefault('Enter <strong>Observer age</strong>',32);

% Melanopsin isolating direction, background
melDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
melDirectionParams.primaryHeadRoom = 0;
melDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3.5);
[MelDirection, MelBackground] = OLDirectionNominalFromParams(melDirectionParams, calibration, 'observerAge', observerAge);

% LMS pulse, on background
LMSPulseParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSPulseParams.primaryHeadRoom = 0;
LMSPulseParams.modulationContrast = [OLUnipolarToBipolarContrast(3.5), OLUnipolarToBipolarContrast(3.5), OLUnipolarToBipolarContrast(3.5)];
[LMSPulseDirection, LMSBackground] = OLDirectionNominalFromParams(LMSPulseParams, calibration, 'observerAge', observerAge);

% LMS flicker, on background
LMSFlickerParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSFlickerParams.primaryHeadRoom = 0;
LMSFlickerParams.modulationContrast = [.05 .05 .05];
LMSFlickerDirection(1) = OLDirectionNominalFromParams(LMSFlickerParams, calibration, 'background', MelBackground, 'observerAge', observerAge);

% LMS flicker, on background+MelDirection
LMSFlickerDirection(4) = OLDirectionNominalFromParams(LMSFlickerParams, calibration, 'background', MelBackground+MelDirection, 'observerAge', observerAge);

% Retrieve the receptors
receptors = LMSFlickerDirection(4).describe.directionParams.T_receptors;

%% Open radiometer, onelight
if ~simulate.radiometer
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end
oneLight = OneLight('simulate',simulate.oneLight);

%% Pre-correction validations
OLValidateDirection(MelDirection, MelBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(LMSPulseDirection, LMSBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(LMSFlickerDirection(1), MelBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(LMSFlickerDirection(4), MelBackground+MelDirection, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');

%% Correct

%% Post-correction validations
OLValidateDirection(MelDirection, MelBackground, oneLight, radiometer, 'receptors', receptors,'label','post-correction');
OLValidateDirection(LMSPulseDirection, LMSBackground, oneLight, radiometer, 'receptors', receptors,'label','post-correction');
OLValidateDirection(LMSFlickerDirection(1), MelBackground, oneLight, radiometer, 'receptors', receptors,'label','post-correction');
OLValidateDirection(LMSFlickerDirection(4), MelBackground+MelDirection, oneLight, radiometer, 'receptors', receptors,'label','post-correction');

%% Display modulations
nextAcquisition = true;
while nextAcquisition
    %% Set modulation parameters 
    % Define constant params:
    pulseDuration = GetWithDefault('Enter <strong>Pulse duration</strong>',4);  % s
    flickerParams.flickerDuration = GetWithDefault('Enter <strong>LMS flicker duration</strong>',.5);  % s
    flickerParams.flickerFrequency = GetWithDefault('Enter <strong>LMS flicker frequency</strong>',5); % Hz
    flickerParams.flickerContrast = GetWithDefault('Enter <strong>LMS flicker contrast</strong>',.05);

    %% Assemble modulations
    pulseWaveformParams = OLWaveformParamsFromName('MaxContrastPulse');
    pulseWaveformParams.stimulusDuration = pulseDuration;
    pulseWaveform = OLWaveformFromParams(pulseWaveformParams);

    modulation(1) = OLAssembleModulation([LMSBackground, LMSPulseDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    modulation(2) = OLAssembleModulation([MelBackground, MelDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    modulation(3) = AssembleModulation_MeLMS(MelBackground,MelDirection,LMSFlickerDirection(1),receptors,2,0,0,flickerParams);
    modulation(4) = AssembleModulation_MeLMS(MelBackground,MelDirection,LMSFlickerDirection(4),receptors,pulseDuration,3,0,flickerParams);
    modulation(5) = AssembleModulation_MeLMS(MelBackground,MelDirection,LMSFlickerDirection(4),receptors,pulseDuration,3,1,flickerParams);
    [MelBackgroundStarts, MelBackgroundStops] = OLPrimaryToStartsStops(MelBackground.differentialPrimaryValues, MelBackground.calibration);
    [LMSBackgroundStarts, LMSBackgroundStops] = OLPrimaryToStartsStops(LMSBackground.differentialPrimaryValues, LMSBackground.calibration);

    %% Keep showing modulations
    nextModulation = true;
    while nextModulation
        % Select modulation
        availableModulations = {'LMS pulse',...
            'MelPulse',...
            'LMS flicker on background',...
            'LMS flicker on Mel pulse (immediate)',...
            'LMS flicker on Mel pulse (1s in)',...
        };
        fprintf('<strong>Available modulations:</strong>\n');
        for i = 1:numel(availableModulations)
            fprintf('\t[%i] %s\n',i,availableModulations{i})
        end
        modulationNo = GetWithDefault('Choose modulation number:',1);

        % Adapt to background
        if modulationNo == 1
            oneLight.setMirrors(LMSBackgroundStarts, LMSBackgroundStops);
        else
            oneLight.setMirrors(MelBackgroundStarts, MelBackgroundStops);
        end
        WaitForKeyPress;

        % Display stimulus
        Beeper;
        OLFlicker(oneLight,modulation(modulationNo).starts,modulation(modulationNo).stops,1/200, 1);
        if modulationNo == 1
            oneLight.setMirrors(LMSBackgroundStarts, LMSBackgroundStops);
        else
            oneLight.setMirrors(MelBackgroundStarts, MelBackgroundStops);
        end
        
        % Get response
        key = WaitForKeyPress;
        if key == 'q'
            nextModulation = false;
        end        
    end
end