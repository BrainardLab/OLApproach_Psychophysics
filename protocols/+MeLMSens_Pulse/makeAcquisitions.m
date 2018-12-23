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
acquisitions(1,1) = MeLMSens_Pulse.acquisition(...
    directions('Mel_low'),...
    directions('MelStep'), false,...
    directions('FlickerDirection_Mel_low'),...
    receptors,...
    'name',"NoPedestal");

%% Mel pedestal (flicker on Mel_high)
acquisitions(2,1) = MeLMSens_Pulse.acquisition(...
    directions('Mel_low'),...
    directions('MelStep'), true,...
    directions('FlickerDirection_Mel_high'),...
    receptors,...
    'name',"Pedestal");

%% Combine
rngSettings = rng('shuffle');
acquisitions = Shuffle(acquisitions);

%% Override params
for i = 1:numel(acquisitions)
    acquisitions(i).NTrialsPerStaircase = parser.Results.NTrialsPerStaircase;
end

%% Intialize
for acquisition = acquisitions(:)'
    acquisition.initializeStaircases();
end
    
end