function binProportionCorrect = binnedProportionCorrect(binnedCorrects)
%STAIRCASEPROPORTIONCORRECT calculate proportion correct staircase response 
%   binPropCorr = proportionCorrect(binnedCorrects) returns a vector of the
%   proportion of logical(true) entries in each cell of the cell-array
%   binnedCorrects

% History:
%   2019.03.27  J.Vincent wrote staircaseProportionCorrect
%   2019.04.22  J.Vincent extracted proportionCorrect

%% Calculate proportion correct
func_propCorrect = @(x) sum(x)/numel(x);
binProportionCorrect = cellfun(func_propCorrect,binnedCorrects);
end