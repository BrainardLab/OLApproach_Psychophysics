function [binProportionCorrect,binCenter,binN] = staircaseProportionCorrect(staircase,varargin)
%STAIRCASEPROPORTIONCORRECT calculate proportion correct staircase response 
%   [binPropCorr, binCenter] = staircaseProportionCorrect(staircase)
%   returns a vector of proportion of correct responses of binned staircase
%   trials. binCenter specifies the center stimulus value of each bin for
%   which proportion correct was calculated.
%
%   [...,binN] = staircaseProportionCorrect(...) also returns the number of
%   trials in each bin.

% History:
%   2019.03.27  J.Vincent wrote staircaseProportionCorrect

%% Parse input
parser = inputParser;
parser.addRequired('staircase',@(x)isa(x,'Staircase'));
parser.parse(staircase, varargin{:});

%% Get binned data
[binStimVals, binResponses, edges] = staircaseBinnedTrials(staircase);

%% Calculate binCenters
binCenter = ((edges(2:end)-edges(1:end-1))/2+edges(1:end-1))'; % calculate centers of bins

%% Calculate binN
binN = cellfun(@numel,binStimVals);

%% Calculate proportion correct
func_propCorrect = @(x) sum(x)/numel(x);
binProportionCorrect = cellfun(func_propCorrect,binResponses);
end