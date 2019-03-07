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

% 400% Melanopsin isolating direction, background
melDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
melDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(4);
[NominalMelDirection, MelBackground] = OLDirectionNominalFromParams(melDirectionParams, calibration, 'observerAge', observerAge, 'alternateBackgroundDictionaryFunc', 'OLBackgroundParamsDictionary_Psychophysics');

% 400% Penumbral direction, background
penumbralDirectionParams = OLDirectionParamsFromName('Penumbral_unipolar_275_60_667', 'alternateDictionaryFunc', 'OLDirectionParamsDictionary_Psychophysics');
[PenumbralDirection, PenumbralBackground] = OLDirectionNominalFromParams(penumbralDirectionParams, calibration, 'observerAge', observerAge, 'alternateBackgroundDictionaryFunc', 'OLBackgroundParamsDictionary_Psychophysics');

% 400% Melanopsin isolating direction, no penumbral cones, background
melNoPenumbralDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
[MelNoPenumbralDirection, MelNoPenumbralBackground] = OLDirectionNominalFromParams(melNoPenumbralDirectionParams, calibration, 'observerAge', observerAge, 'alternateBackgroundDictionaryFunc', 'OLBackgroundParamsDictionary_Psychophysics');

% 400% LMS pulse, on background
LMSPulseParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSPulseParams.primaryHeadRoom = 0;
LMSPulseParams.modulationContrast = [OLUnipolarToBipolarContrast(3.5), OLUnipolarToBipolarContrast(3.5), OLUnipolarToBipolarContrast(3.5)];
[LMSPulseDirection, LMSBackground] = OLDirectionNominalFromParams(LMSPulseParams, calibration, 'observerAge', observerAge);

% 5% LMS flicker, on MelBackground
LMSFlickerParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSFlickerParams.primaryHeadRoom = 0;
LMSFlickerParams.modulationContrast = [.03 .03 .03];
LMSFlickerDirection(1) = OLDirectionNominalFromParams(LMSFlickerParams, calibration, 'background', MelBackground, 'observerAge', observerAge);

% 5% LMS flicker, on MelBackground+MelDirection
scaledMelDirection = NominalMelDirection.ScaleToReceptorContrast(MelBackground,receptors,[0; 0; 0; 3]);
LMSFlickerDirection(4) = OLDirectionNominalFromParams(LMSFlickerParams, calibration, 'background', MelBackground+scaledMelDirection, 'observerAge', observerAge);

% Retrieve the receptors
receptors = MelNoPenumbralDirection.describe.directionParams.T_receptors;

%% Open radiometer, onelight
if ~simulate.radiometer
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end
oneLight = OneLight('simulate',simulate.oneLight);

%% Pre-correction validations
OLValidateDirection(NominalMelDirection, MelBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(PenumbralDirection, PenumbralBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(MelNoPenumbralDirection, MelNoPenumbralBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(LMSPulseDirection, LMSBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(scaledMelDirection, MelBackground, oneLight, radiometer, 'receptors', receptors, 'label', 'pre-correction');
OLValidateDirection(LMSFlickerDirection(1), MelBackground, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');
OLValidateDirection(LMSFlickerDirection(4), MelBackground+scaledMelDirection, oneLight, radiometer, 'receptors', receptors,'label','pre-correction');

%% Correct
correctedMelDirection = NominalMelDirection.copy();
correctedMelDirection.describe.photoreceptorClasses = correctedMelDirection.describe.directionParams.photoreceptorClasses;
correctedMelDirection.describe.T_receptors = correctedMelDirection.describe.directionParams.T_receptors;
correctedMelBackground = MelBackground.copy();
OLCorrectDirection(correctedMelDirection, correctedMelBackground, oneLight, radiometer, 'legacyMode', true, 'smoothness', .1);

%% Post-correction validations
OLValidateDirection(correctedMelDirection, correctedMelBackground, oneLight, radiometer, 'receptors', receptors,'label','post-correction');

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
    pulseWaveformParams.timeStep = 1/200;
    pulseWaveformParams.stimulusDuration = pulseDuration;
    pulseWaveform = OLWaveformFromParams(pulseWaveformParams);

    modulation(1) = OLAssembleModulation([LMSBackground, LMSPulseDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    modulation(2) = OLAssembleModulation([MelBackground, NominalMelDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    modulation(3) = OLAssembleModulation([MelBackground, scaledMelDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    modulation(4) = OLAssembleModulation([MelNoPenumbralBackground, MelNoPenumbralDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    modulation(5) = OLAssembleModulation([correctedMelBackground, correctedMelDirection],[ones(1,length(pulseWaveform)); pulseWaveform]);
    %modulation(6) = AssembleModulation_MeLMS(MelBackground,scaledMelDirection,LMSFlickerDirection(1),receptors,2,0,0,flickerParams);
    %modulation(7) = AssembleModulation_MeLMS(MelBackground,scaledMelDirection,LMSFlickerDirection(4),receptors,pulseDuration,3,0,flickerParams);
    %modulation(8) = AssembleModulation_MeLMS(MelBackground,scaledMelDirection,LMSFlickerDirection(4),receptors,pulseDuration,3,1,flickerParams);
    [MelBackgroundStarts, MelBackgroundStops] = OLPrimaryToStartsStops(MelBackground.differentialPrimaryValues, MelBackground.calibration);
    [LMSBackgroundStarts, LMSBackgroundStops] = OLPrimaryToStartsStops(LMSBackground.differentialPrimaryValues, LMSBackground.calibration);
    [MelNoPenumbralBackgroundStarts, MelNoPenumbralBackgroundStops] = OLPrimaryToStartsStops(MelNoPenumbralBackground.differentialPrimaryValues, LMSBackground.calibration);
    [correctedMelBackgroundStarts, correctedMelBackgroundStops] = OLPrimaryToStartsStops(correctedMelBackground.differentialPrimaryValues, LMSBackground.calibration);
   
    %% Keep showing modulations
    nextModulation = true;
    while nextModulation
        % Select modulation
        availableModulations = {'LMS pulse',...
            '400% MelPulse nominal',...
            '350% MelPulse nominal',...
            '400% MelPulse, no penumbral',...
            '400% MelPulse corrected',...
            'LMS flicker on background',...
            'LMS flicker on 400% Mel pulse (immediate)',...
            'LMS flicker on 400% Mel pulse (1s in)',...
        };
        fprintf('<strong>Available modulations:</strong>\n');
        for i = 1:numel(availableModulations)
            fprintf('\t[%i] %s\n',i,availableModulations{i})
        end
        modulationNo = GetWithDefault('Choose modulation number:',1);

        % Adapt to background
        switch modulationNo
            case 1
                oneLight.setMirrors(LMSBackgroundStarts, LMSBackgroundStops);
            case {2, 3}
                oneLight.setMirrors(MelBackgroundStarts, MelBackgroundStops);
            case 4
                oneLight.setMirrors(MelNoPenumbralBackgroundStarts, MelNoPenumbralBackgroundStops);
            case 5
                oneLight.setMirrors(correctedMelBackgroundStarts, correctedMelBackgroundStops);
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
        if ischar(key) && key == 'q'
            nextModulation = false;
        end        
    end
end