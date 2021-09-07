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
binIdx(binIdx==0)=1; % binIdx as returned from histcounts is [0,N], which won't do for indexing.

% bin stimulus values
binStimVals = Staircases.binMatToCell(values,binIdx,length(binN));

% bin responses
binResponses = Staircases.binMatToCell(responses,binIdx,length(binN));
end