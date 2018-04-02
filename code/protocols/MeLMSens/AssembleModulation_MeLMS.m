function modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection, pulseDuration, pulseContrast, flickerDuration, flickerLag, flickerFrequency, flickerContrast, receptors)
% Assembles trial of LMS flicker on Mel pulse
%
% Syntax:
%
% Description:
%    Detailed explanation goes here
%
% Inputs:
%    background      - 
%    MelDirection    -
%    LMSDirection    - 
%    pulseDuration   - 
%    pulseContrast   - 
%    flickerDuration - 
%    flickerLag      -
%    flickerContrast - 
%
% Outputs:
%    modulation      - 
%
% Optional key/values pairs:
%    None.
%
% See also:
%

% History:
%    03/28/18  jv  wrote it.

%% Input validation

%% Create pulse waveform
pulseParams = OLWaveformParamsFromName('MaxContrastPulse');
pulseParams.timeStep = 1/200;
pulseParams.stimulusDuration = pulseDuration;
[pulseWaveform, timestep] = OLWaveformFromParams(pulseParams);

%% Create cone flicker
flickerParams = OLWaveformParamsFromName('MaxContrastSinusoid');
flickerParams.frequency = flickerFrequency;
flickerParams.timeStep = 1/200;
flickerParams.stimulusDuration = flickerDuration;
flickerParams.cosineWindowIn = false;
flickerParams.cosineWindowOut = false;
flickerWaveform = OLWaveformFromParams(flickerParams);

%% Add lag, pad flicker
t0FlickerSecs = flickerLag;
if pulseParams.cosineWindowIn
    t0FlickerSecs = t0FlickerSecs + pulseParams.cosineWindowDurationSecs;
end
t0FlickerFrame = t0FlickerSecs / timestep;
flickerWaveform = OLPadWaveformToReference([zeros(1,t0FlickerFrame) flickerWaveform],pulseWaveform,'leadingTrailing','trailing');

%% Scale pulse
% Inputs to this function defining contrast are in receptor contrasts.
% This requires determining by how much to scale the direction to match the
% desired receptor contrast. If the directions are validated, scale the
% measured receptor contrast. If not, use the nominal contrast in the
% params (assuming that directions are generated from params)

% Mel contrast
scaledMel = ScaleToReceptorContrast(MelDirection, background, receptors, [0 0 0 pulseContrast]');

% LMS contrast
scaledLMS = ScaleToReceptorContrast(LMSDirection, background+scaledMel, receptors, [flickerContrast flickerContrast flickerContrast 0]');

%% Assemble
modulation = OLAssembleModulation([background, scaledMel, scaledLMS],[ones(1,length(pulseWaveform)); pulseWaveform; flickerWaveform]);
modulation.timestep = 1/200;

end