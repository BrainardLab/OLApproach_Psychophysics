function staircase = makeStaircase(NTrialsPerStaircase)
%MAKESTAIRCASE Summary of this function goes here
%   Detailed explanation goes here
staircase = Staircases.InterleavedStaircase;
staircase.stimulusStep = 1;
staircase.stimulusMin = 0;
staircase.stimulusMax = 127;
staircase.NTrialsPerStaircase = NTrialsPerStaircase;
staircase.stepSizes = [16 8 4 2 1];
end