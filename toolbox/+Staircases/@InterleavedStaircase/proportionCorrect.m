function [binProportionCorrect,binCenter,binN] = proportionCorrect(obj)
%PROPORTIONCORRECT returns proportion of correct responses per bin staircase stimulus levels

% History:
%   2019.03.27  J.Vincent wrote staircaseBinnedTrials
%   2019.04.22  J.Vincent
[binnedStimulusLevels, binEdges, binnedCorrects] = obj.binnedTrials();
binCenter = Staircases.binEdgesToCenter(binEdges);
binN = cellfun(@numel,binnedStimulusLevels);
binProportionCorrect = Staircases.binnedProportionCorrect(binnedCorrects);
end