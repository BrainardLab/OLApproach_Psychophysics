function modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection, pulseDuration, pulseContrast, flickerDuration, flickerLag, flickerContrast)
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
flickerParams.frequency = 15;
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
if isfield(MelDirection.describe,'validation') && ~isempty(MelDirection.describe.validation)
    maxMelContrast = MelDirection.describe.validation(end).contrastActual(4,1); % maximum Mel contrast
else
    maxMelContrast = OLBipolarToUnipolarContrast(MelDirection.describe.directionParams.modulationContrast);
end
assert(pulseContrast < maxMelContrast,'OLApproach_Psychophysics:AssembleTrial_MeLMS:MaxContrast',...
    'Desired melanopsin contrast is higher than max contrast');
melScale = pulseContrast / maxMelContrast;
pulseWaveform = melScale * pulseWaveform;

%% Scale flicker
% LMS contrast
if isfield(LMSDirection.describe,'validation') && ~isempty(LMSDirection.describe.validation)
    maxLMSContrast = max(LMSDirection.describe.validation(end).contrastActual(1:3,1)); % maximum Mel contrast
else
    maxLMSContrast = LMSDirection.describe.directionParams.modulationContrast;
end
assert(flickerContrast < maxLMSContrast,'OLApproach_Psychophysics:AssembleTrial_MeLMS:MaxContrast',...
    'Desired LMS contrast is higher than max contrast');
LMSScale = flickerContrast / maxLMSContrast;
flickerWaveform = LMSScale * flickerWaveform;

%% Assemble
modulation = OLAssembleModulation([background, MelDirection, LMSDirection],[ones(1,length(pulseWaveform)); pulseWaveform; flickerWaveform]);
modulation.timestep = 1/200;

end