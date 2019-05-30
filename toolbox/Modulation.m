classdef Modulation < handle & matlab.mixin.Heterogeneous
% Abstract superclass for temporal modulation of color directions
%
% Description:
%    A modulation is a temporal variation of the device primaries, from a
%    background in a certain direction. This function takes in
%    specifications of directions in primary space, and temporal waveforms
%    for each direction, and combines them into a single modulation.
%
% Properties:
%    directions      - specifications of the directions to create 
%                      modulation of.
%    waveforms       - NxT matrix of differential scalars (in range [-1,1])
%                      on each of the N directions, at each timepoint T.
%    framerate       - framerate / sampling rate (in Hz)
%
%    (Dependent)
%    primaryWaveform - PxT matrix of device primary P power value at each 
%                      timepoint T
%
% Methods:
%    (Abstract)
%    show()          - display modulation on given hardware
%

% History:
%    07/21/17  dhb       Tried to improve comments.
%    08/09/17  dhb, mab  Compute pos/neg diff more flexibly.
%    01/29/18  dhb, jv   Moved waveform generation to OLWaveformFromParams.
%    01/30/18  jv        Updated to use the new OLPrimaryWaveform and
%                        OLPrimaryStartsStops machinery.
%                        Takes in a waveform vector, rather than params.
%    03/09/18  jv        Work with OLDirection objects
%    04/16/18  jv        OLModulation-class, DisplayObjectModulation class,
%                        Modulation abstract superclass

    properties (Abstract)
        directions;
    end
    properties
        waveforms;
        framerate(1,1) {mustBePositive,mustBeReal,mustBeFinite} = 1;        % Framerate / refresh rate (Hz) of device        
        hasBeep(1,1) = false;
    end
    properties (Abstract, Dependent)
        primaryWaveform;
    end
    methods (Abstract)
        show(obj, hardware);
    end
    methods
        function beep(obj)
            if obj.hasBeep
                Beeper;
            end
        end
    end
end