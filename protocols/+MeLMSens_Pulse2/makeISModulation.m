function ISModulation = makeISModulation(background, pedestalDirection, pedestalContrast, ISDuration, framerate)
% Create modulation for interstimulus interval of stimulus
%
% Syntax:
%	Stimulus.makeISModulation()
%	makeISModulation(stimulus)
%
% Description:
%    Make modulation for the interstimulus interval of given stimulus.
%    IS modulation consists of just the background, and if stimulus
%    contains a pedestal contrast, also this pedestal at specified
%    contrast.
%
% Inputs:
%    stimulus     - scalar object of class Stimulus, with valid background,
%                   pedestal direction
%
% Outputs:
%    ISModulation - struct with fields defining reference modulation
%
% Optional keyword arguments:
%    None.
%
% See also:
%    OLAssembleModulation

% History:
%    02/19/19  jv   wrote MeLMSuper.makeISModulation;

%% Set up waveforms
% constant at 1
ISWaveform = constant(ISDuration,framerate);

%% Scale pedestal direction to contrast
if pedestalContrast
    scaledPedestalDirection = pedestalDirection;
else
    scaledPedestalDirection = 0.*pedestalDirection;
end

%% Assemble modulation
ISModulation = OLModulation(); % initialize object
ISModulation.directions = [background scaledPedestalDirection];
ISModulation.waveforms = [ISWaveform; ISWaveform];
ISModulation.hasBeep = false;
end