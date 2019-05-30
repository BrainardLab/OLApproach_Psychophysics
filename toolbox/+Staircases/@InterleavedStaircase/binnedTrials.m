function [binStimLevels,binEdges,binCorrects] = binnedTrials(obj)
%BINNEDTRIALS Bin interleaved staircases trials by stimulus value
%   binStimVals = InterleavedStaircase.binnedTrials() bins the trials in
%   staircase according to the stimulus value. binStimVals is a cell array,
%   with one cell per bin, containing a numeric vector of stimulus values
%   in that bin
%
%   [binStimVals, binResponses] = staircaseBinnedTrials(...) also returns a
%   cell array containing logical vectors with the responses corresponding
%   to each bins stimulus values
%
%   [...,binEdges] = staircaseBinnedTrials(...) returns the values of the
%   bin edges, as returned by histcounts
%
%   See also Staircase.getTrials, histcounts, binMatToCell

% History:
%   2019.03.27  J.Vincent wrote staircaseBinnedTrials
%   2019.04.22  J.Vincent adapted for InterleavedStaircases

values = obj.stimulusLevels(:);
responses = obj.corrects(:);

[binStimLevels, binEdges, binCorrects] = Staircases.binStimulusLevelsCorrects(values,responses);

end