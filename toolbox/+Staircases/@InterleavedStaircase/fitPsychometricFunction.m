function PFParams = fitPsychometricFunction(obj, psychometricFunction, paramsFree, initialParamsGuess,lapseLimits)
%FITPSYCHOMETRICFUNCTION Summary of this function goes here
%
% Fit with Palemedes Toolbox. Really want to plot the fit
% against the data to make sure it is reasonable in practice.
%
% Define what psychometric functional form to fit.
% Alternatives: PAL_Gumbel, PAL_Weibull, PAL_CumulativeNormal,
% PAL_HyperbolicSecant
%
% PAL psychometric functions take in the following arguments:
% stimLevels - vector of stimulusLevels used
%
% nCorrect - number of correct responses for each stim level
%
% n - number of total trials for each stim level
%
% PF - handle to psychometric function
% paramsFree - boolean vector that determines what parameters get searched
%              over. 1: free parameter, 0: fixed parameter
%              initialParamsGuess initial guess of parameter values
%
% stimLevels, nCorrect, and n are provided by this method;
% PF, paramsFree, and initialParamsGuess must be provided as input
% arguments to this method.

%%
stimulusLevels = unique(obj.stimulusLevels);
for i = 1:length(stimulusLevels)
    n(i) = sum(obj.stimulusLevels(:) == stimulusLevels(i));
    nCorrect(i) = sum(obj.corrects(obj.stimulusLevels == stimulusLevels(i)));
end

%% Set up standard options for Palamedes search
options = PAL_minimize('options');

%% Do the search to get the parameters
PFParams = PAL_PFML_Fit(...
    stimulusLevels,nCorrect',n', ...
    initialParamsGuess,paramsFree,...
    psychometricFunction,...
    'searchOptions',options,...
    'lapseLimits',lapseLimits);
end