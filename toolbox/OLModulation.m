classdef OLModulation < Modulation
% Class for temporal modulation of color direction on OneLight device
%
% Description:
%    A modulation is a temporal variation of the device primaries, from a
%    background in a certain direction. This function takes in
%    OLDirection objects specifying directions in primary space, and
%    temporal waveforms for each direction, and combines them into a single
%    modulation.
%
% Properties:
%    directions      - OLDirection objects specifying the directions to 
%                      create modulation of.
%    waveforms       - NxT matrix of differential scalars (in range [-1,1])
%                      on each of the N directions, at each timepoint T.
%    framerate       - framerate / sampling rate (in Hz)
%
%    (Dependent)
%    primaryWaveform - PxT matrix of device primary P power value at each 
%                      timepoint T
%    predictedSPDs   - Predicted SPD at each timepoint
%    starts, stops   - starts and stops to put this primaryWaveform on OL
%
% Methods:
%    show(OneLight)  - display modulation on given oneLight
%
% See also:
%    OLAssembleModulation, OLDirection, OLPrimaryWaveform

% History:
%    07/21/17  dhb       Tried to improve comments.
%    08/09/17  dhb, mab  Compute pos/neg diff more flexibly.
%    01/29/18  dhb, jv   Moved waveform generation to OLWaveformFromParams.
%    01/30/18  jv        Updated to use the new OLPrimaryWaveform and
%                        OLPrimaryStartsStops machinery.
%                        Takes in a waveform vector, rather than params.
%    03/09/18  jv        Work with OLDirection objects
%    04/16/18  jv        OLModulation-class

    properties
        directions;                                                        % OLDirections to apply in waveform
    end
    properties (Dependent)
        primaryWaveform; % PxT matrix of device primary P power value at each timepoint T
        predictedSPDs;   % Predicted SPD at each timepoint
        starts;          % starts to put this primaryWaveform on OL
        stops;           % stops to put this primaryWaveform on OL
    end
    
    methods
        function obj = OLModulation(varargin)
            parser = inputParser;
            parser.addParameter('modulationStruct',struct([]),@isstruct);
            parser.parse(varargin{:});
            
            if ~isempty(parser.Results.modulationStruct)
                modulationStruct = parser.Results.modulationStruct;
                obj.directions = modulationStruct.directions;
                obj.waveforms = modulationStruct.waveforms;
                assert(all(obj.primaryWaveform(:) == modulationStruct.primaryWaveform(:)));
            end
            
            obj.framerate = 200;
        end
        
        function primaryWaveform = get.primaryWaveform(obj)
            primaryWaveform = OLPrimaryWaveform(obj.directions, obj.waveforms);
        end
        function predictedSPDs = get.predictedSPDs(obj)
            predictedSPDs = OLPrimaryToSpd(obj.directions(1).calibration,obj.primaryWaveform);      
        end
        function starts = get.starts(obj)
            [starts, ~] = OLPrimaryToStartsStops(obj.primaryWaveform,obj.directions(1).calibration);
        end
        function stops = get.stops(obj)
            [~, stops] = OLPrimaryToStartsStops(obj.primaryWaveform,obj.directions(1).calibration);            
        end
        
        function show(obj, oneLight)
            OLFlicker(oneLight, obj.starts, obj.stops, 1/obj.framerate, 1);         
        end
    end
end