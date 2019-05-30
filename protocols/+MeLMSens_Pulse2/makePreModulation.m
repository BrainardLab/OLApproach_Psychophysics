function preModulation = makePreModulation(background, pedestalDirection, pedestalContrast, cosineDuration, framerate)
% Create modulation for preceding all intervals
%
% Syntax:
%   Stimulus.makePreModulation()
%   makePreModulation(stimulus)
%
% Description:
%    Make modulation for the timeblock preceding any intervals of given
%    stimulus. Pre modulation consists of just the background, and if
%    stimulus contains a pedestal contrast, a cosine ramp up to this
%    pedestal, followed by a steady state at the pedestal.
%
% Inputs:
%    stimulus      - scalar object of class Stimulus, with valid
%                    background, pedestal direction
%
% Outputs:
%    preModulation - struct with fields defining pre modulation
%
% Optional keyword arguments:
%    None.
%
% See also:
%    OLAssembleModulation

% History:
%    02/19/19  jv   wrote MeLMSuper.makePreModulation;

%% Set up waveforms
% cosine-window 0 -> 1
cosineWaveform = cosineRamp(cosineDuration,framerate);
rampOnWaveform = [cosineWaveform, constant(seconds(.25),framerate)];

%% Scale pedestal direction to contrast
if pedestalContrast
    scaledPedestalDirection = pedestalDirection;
else
    scaledPedestalDirection = 0.*pedestalDirection;
end

%% Assemble modulation
preModulation = OLModulation();
preModulation.directions = [background scaledPedestalDirection];
preModulation.waveforms = [ones(1,length(rampOnWaveform)); rampOnWaveform];
preModulation.hasBeep = false;
end