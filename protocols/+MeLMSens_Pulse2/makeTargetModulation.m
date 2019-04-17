function targetModulation = makeTargetModulation(flickerBackgroundRGB, flickerDeltaRGB, flickerFrequency, flickerDuration, framerate)
% Create modulation for target interval of stimulus
%
% Syntax:
%   Stimulus.makeTargetModulation()
%   makeTargetModulation(stimulus)
%
% Description:
%    Make modulation for the target interval of given stimulus. Target
%    modulation consists of bipolar sinusoidal flicker, at specificied
%    bipolar contrast. If stimulus contains a pedestal contrast, this
%    target flicker is constructed on the background + pedestal direction
%    (at contrast); otherwise just on the background. Also adds a beep to
%    the modulation.
%
% Inputs:
%    stimulus - scalar object of class Stimulus, with valid background,
%               pedestal direction
%
% Outputs:
%    targetModulation - struct with fields defining target modulation
%
% Optional keyword arguments:
%    None.
%
% See also:
%    OLAssembleModulation

% History:
%    02/19/19  jv   wrote MeLMSuper.Stimulus.makeTargetModulation;

%% Set up waveforms
% sinusoid
flickerWaveform = sinewave(flickerDuration,framerate,flickerFrequency);

% constant at 1
referenceWaveform = ones(1,length(flickerWaveform));

%% Assemble modulation
targetModulation = projectorSpot.DisplayObjectModulation();
targetModulation.directions = [flickerBackgroundRGB flickerDeltaRGB]; 
targetModulation.waveforms = [referenceWaveform; flickerWaveform];
targetModulation.hasBeep = true;
end