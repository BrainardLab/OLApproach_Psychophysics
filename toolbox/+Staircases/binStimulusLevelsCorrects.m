function [binStimLevels,binEdges,binCorrects] = binStimulusLevelsCorrects(stimulusLevels,varargin)
%STAIRCASEBINNEDTRIALS Bin vectors of stim levels, corresponding (in)correct responses
%   binStimLevels = binStimulusLevelsCorrects(stimulusLevels)
%   bins the vector of stimulus values. binStimLevels is a cell array, with
%   one cell per bin, containing a numeric vector of stimulus values in
%   that bin
%
%   [..., binEdges] = binStimulusLevelsCorrects(...) returns the values of the
%   bin edges, as returned by histcounts
%
%   [..., binCorrects] = binStimulusLevelsCorrects(...,
%   corrects) also returns a cell array containing logical vectors with the
%   responses corresponding to each bins stimulus values
%
%   See also: histcounts, binMatToCell

% History:
%   2019.03.27  J.Vincent wrote staircaseBinnedTrials
%   2019.04.22  J.Vincent extracted binStimulusLevelsCorrects

%% Parse input
parser = inputParser();
parser.addRequired('stimulusLevels');
parser.addOptional('corrects',[]);
parser.addParameter('binWidth',1);
parser.parse(stimulusLevels, varargin{:});
corrects = parser.Results.corrects;

%% Bin stimulus levels
% Get bin edges, indices
[binN, binEdges, binIdx] = histcounts(stimulusLevels,'BinWidth',parser.Results.binWidth); % bin the stim values

% Deal with 0th bin
if min(binEdges > 0)
    binEdges = [0 binEdges];
    binN = [sum(binIdx == 0) binN];
    binIdx = binIdx+1;
end

% bin stimulus values
binStimLevels = Staircases.binMatToCell(stimulusLevels,binIdx);

%% Bin corrects
if nargout == 3
    assert(~isempty(corrects),'No vector of response specified');
    
    % bin responses
    binCorrects = Staircases.binMatToCell(corrects,binIdx);
end
end