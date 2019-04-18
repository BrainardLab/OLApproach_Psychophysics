function staircase = makeStaircase()
%MAKESTAIRCASE Summary of this function goes here
%   Detailed explanation goes here
staircase = Staircases.InterleavedStaircase;
staircase.stimulusStep = 1;
staircase.stimulusMin = 0;
staircase.stimulusMax = 30;
staircase.NTrialsPerStaircase = 40;
staircase.stepSizes = [16 8 4 2 1];
end