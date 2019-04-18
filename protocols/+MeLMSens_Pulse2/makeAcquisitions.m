function acquisitions = makeAcquisitions(directions, receptors, varargin)
%MAKEACQUISITIONST Summary of this function goes here
%   Detailed explanation goes here
%% Parse input
parser = inputParser;
parser.addRequired('directions');
parser.addRequired('receptors');
parser.addParameter('NTrialsPerStaircase',40);
parser.parse(directions, receptors, varargin{:});

%% No pedestal (flicker on Mel_low)
acquisitions(1,1) = MeLMSens_Pulse2.Acquisition();
acquisitions(1,1).background = directions('Mel_low');
acquisitions(1,1).pedestalDirection = directions('MelStep');
acquisitions(1,1).pedestalPresent = 0;
acquisitions(1,1).name = "NoPedestal";

%% Mel pedestal (flicker on Mel_high)
acquisitions(2,1) = MeLMSens_Pulse2.Acquisition();
acquisitions(2,1).background = directions('Mel_low');
acquisitions(2,1).pedestalDirection = directions('MelStep');
acquisitions(2,1).pedestalPresent = 1;
acquisitions(2,1).name = "Pedestal";

%% Combine
rngSettings = rng('shuffle');
acquisitions = Shuffle(acquisitions);

%% Intialize
for acquisition = acquisitions(:)'
    acquisition.makeModulations();
    acquisition.staircase = MeLMSens_Pulse2.makeStaircase(parser.Results.NTrialsPerStaircase);    
    acquisition.staircase.initialize();
end
    
end