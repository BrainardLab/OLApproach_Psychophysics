classdef DisplayObjectModulation < Modulation
% Class for temporal modulation of color direction on OneLight device
%
% Description:
%    A modulation is a temporal variation of the device primaries, from a
%    background in a certain direction. This function takes in RGB-values
%    (3xN N column vectors) specifying directions in primary (RGB) space, and
%    temporal waveforms for each direction, and combines them into a single
%    modulation.
%
% Properties:
%    directions      - 3xN matrix specifying the primary (RGB) directions
%                      to create modulation of.
%    waveforms       - NxT matrix of differential scalars (in range [-1,1])
%                      on each of the N directions, at each timepoint T.
%    framerate       - framerate / sampling rate (in Hz)
%
%    (Dependent)
%    primaryWaveform - 3xT matrix of device primary [R,G,B] power value at
%                      each timepoint T
%
% Methods:
%    show(displayObject)  - display modulation on given DisplayObject
%
% See also:
%    

% History:
%    07/21/17  dhb       Tried to improve comments.
%    08/09/17  dhb, mab  Compute pos/neg diff more flexibly.
%    01/29/18  dhb, jv   Moved waveform generation to OLWaveformFromParams.
%    01/30/18  jv        Updated to use the new OLPrimaryWaveform and
%                        OLPrimaryStartsStops machinery.
%                        Takes in a waveform vector, rather than params.
%    03/09/18  jv        Work with OLDirection objects
%    04/16/18  jv        OLModulation-class
%                        adapted into DisplayObjectModulation class

    properties
        directions;                                                        % 3xN RGB primary values for N directions, to add in primary waveform
    end
    properties (Dependent)
        primaryWaveform; % Primary (RGB) values at each frame, matrix mult of directions * waveforms                                                  
    end
    
    methods
        function obj = DisplayObjectModulation()
            obj.framerate = 60;
        end
        function primaryWaveform = get.primaryWaveform(obj)
            primaryWaveform = OLPrimaryWaveform(obj.directions, obj.waveforms);
        end
        
        function show(obj, displayObject)
            obj.beep();
            displayObject.flickerRGB(obj.primaryWaveform,obj.framerate);
        end
    end
end