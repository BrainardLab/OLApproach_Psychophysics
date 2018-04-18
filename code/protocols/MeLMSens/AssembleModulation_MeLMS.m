function modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection, receptors, varargin)
% Assembles trial of LMS flicker on Mel pulse
%
% Syntax:
%
% Description:
%    Detailed explanation goes here
%
% Inputs:
%    background       - 
%    MelDirection     -
%    LMSDirection     - 
%    receptors        -
%    pulseDuration    - 
%    pulseContrast    - 
%    flickerDuration  - 
%    flickerLag       -
%    flickerFrequency - 
%    flickerContrast  - 
%
% Outputs:
%    modulation       - 
%
% Optional key/values pairs:
%    None.
%
% See also:
%

% History:
%    03/28/18  jv  wrote it.

%% Input validation
parser = inputParser();
parser.addRequired('background');
parser.addRequired('MelDirection');
parser.addRequired('LMSDirection');
parser.addRequired('receptors');
parser.addOptional('pulseDuration',[]);
parser.addOptional('pulseContrast',[]);
parser.addOptional('flickerLag',[]);
parser.addOptional('flickerDuration',[]);
parser.addOptional('flickerFrequency',[]);
parser.addOptional('flickerContrast',[]);
parser.StructExpand = true;
parser.parse(background, MelDirection, LMSDirection, receptors, varargin{:});

%% Create pulse waveform
pulseParams = OLWaveformParamsFromName('MaxContrastPulse');
pulseParams.timeStep = 1/200;
pulseParams.stimulusDuration = parser.Results.pulseDuration;
[pulseWaveform, timestep] = OLWaveformFromParams(pulseParams);

%% Create cone flicker
flickerParams = OLWaveformParamsFromName('MaxContrastSinusoid');
flickerParams.frequency = parser.Results.flickerFrequency;
flickerParams.timeStep = 1/200;
flickerParams.stimulusDuration = parser.Results.flickerDuration;
flickerParams.cosineWindowIn = false;
flickerParams.cosineWindowOut = false;
flickerWaveform = OLWaveformFromParams(flickerParams);

%% Add lag, pad flicker
t0FlickerSecs = parser.Results.flickerLag;
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
pulseContrast = parser.Results.pulseContrast;
if pulseContrast == 0
    scaledMel = 0 .* MelDirection;
else
    scaledMel = ScaleToReceptorContrast(MelDirection, background, receptors, [0 0 0 pulseContrast]');
end

% LMS contrast
flickerContrast = parser.Results.flickerContrast;
scaledLMS = ScaleToReceptorContrast(LMSDirection, background+scaledMel, receptors, [flickerContrast flickerContrast flickerContrast 0]');

%% Assemble
modulation = OLAssembleModulation([background, scaledMel, scaledLMS],[ones(1,length(pulseWaveform)); pulseWaveform; flickerWaveform]);
modulation.timestep = 1/200;

end