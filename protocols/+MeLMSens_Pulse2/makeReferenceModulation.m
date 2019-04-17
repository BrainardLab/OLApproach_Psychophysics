function referenceModulation = makeReferenceModulation(flickerBackgroundRGB, flickerDuration, framerate)
% Create modulation for reference interval of stimulus
%
% Syntax:
%   Stimulus.makeReferenceModulation()
%   makeReferenceModulation(stimulus)
%
% Description:
%    Make modulation for the reference interval of given stimulus.
%    Reference modulation consists of just the background, and if stimulus
%    contains a pedestal contrast, also this pedestal at specified
%    contrast. The reference modulation contains the same number of
%    frames as the target modulation.
%
% Inputs:
%    stimulus            - scalar object of class Stimulus, with valid
%                          background, pedestal direction
%
% Outputs:
%    referenceModulation - struct with fields defining reference modulation
%
% Optional keyword arguments:
%    None.
%
% See also:
%    OLAssembleModulation

% History:
%    02/19/19  jv   wrote MeLMSuper.makeReferenceModulation;

%% Set up waveforms
% constant at 1
referenceWaveform = constant(seconds(flickerDuration),framerate);

%% Assemble modulation
referenceModulation = projectorSpot.DisplayObjectModulation();
referenceModulation.directions = flickerBackgroundRGB;
referenceModulation.waveforms = referenceWaveform;
referenceModulation.hasBeep = true;

end