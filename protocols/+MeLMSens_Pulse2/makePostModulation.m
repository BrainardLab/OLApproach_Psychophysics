function postModulation = makePostModulation(background, pedestalDirection, pedestalContrast, cosineDuration, framerate)
% Create modulation for postceding all intervals
%
% Syntax:
%   Stimulus.makePostModulation()
%   makePostModulation(stimulus)
%
% Description:
%    Make modulation for the timeblock postceding any intervals of given
%    stimulus. post modulation consists of just the background, and if
%    stimulus contains a pedestal contrast, a cosine ramp up down from this
%    pedestal, preceded by a steady state at the pedestal.
%
% Inputs:
%    stimulus       - scalar object of class Stimulus, with valid
%                     background, pedestal direction
%
% Outputs:
%    postModulation - struct with fields defining post modulation
%
% Optional keyword arguments:
%    None.
%
% See also:
%    OLAssembleModulation

% History:
%    02/19/19  jv   wrote MeLMSuper.makePostModulation;

%% Set up waveforms
% cosine-window 0 -> 1
cosineWaveform = cosineRamp(cosineDuration,framerate);

% cosine-window 1 -> 0
rampOffWaveform = [constant(seconds(.25),framerate), fliplr(cosineWaveform)];

%% Scale pedestal direction to contrast
if pedestalContrast
    scaledPedestalDirection = pedestalDirection;
else
    scaledPedestalDirection = 0.*pedestalDirection;
end

%% Assemble modulation
postModulation = OLModulation();
postModulation.directions = [background scaledPedestalDirection];
postModulation.waveforms = [ones(1,length(rampOffWaveform)); rampOffWaveform];
postModulation.hasBeep = false;
end