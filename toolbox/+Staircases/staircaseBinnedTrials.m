function [binStimVals,binResponses,binEdges] = staircaseBinnedTrials(staircase,varargin)
%STAIRCASEBINNEDTRIALS Bin staircase trials by stimulus value
%   binStimVals = staircaseBinnedTrials(staircase) bins the trials in
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

%% Parse input
parser = inputParser;
parser.addRequired('staircase',@(x)isa(x,'Staircase'));
parser.parse(staircase, varargin{:});

%% Extract values, correct/incorrect
values = [];
responses = [];
for s = staircase
    [value, correct] = getTrials(s); % extract data from single staircase
    values = vertcat(values, value(:)); % cat stim values in rowvector
    responses = vertcat(responses, correct(:)); % cat responses in rowvector
end
responses = logical(responses); % cast responses to true/false
values = round(values,8); % round stim values to 8 decimals

%% Bin data
% Get bin edges, indices
edges = 0:0.001:0.05;
[binN, binEdges, binIdx] = histcounts(values,edges); % bin the stim values

% Deal with 0th bin
if min(binEdges > 0)
    binEdges = [0 binEdges];
    binN = [sum(binIdx == 0) binN];
    binIdx = binIdx+1;
end

% bin stimulus values
binStimVals = Staircases.binMatToCell(values,binIdx);

% bin responses
binResponses = Staircases.binMatToCell(responses,binIdx);
end