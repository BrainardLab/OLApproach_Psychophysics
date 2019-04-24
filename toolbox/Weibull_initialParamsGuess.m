function initialParamsGuess = Weibull_initialParamsGuess(stimulusLevels, guessRate)
%WEIBULL_INITIALPARAMSGUESS Summary of this function goes here
%   Detailed explanation goes here

% Define initial parameter guesses.
initialParamsGuess = [];

% The first two parameters of the Weibull define its shape.
% Setting the first parameter to the middle of the stimulus
% range and the second to 1 puts things into a reasonable
% ballpark here.
initialParamsGuess(1) = mean([max(stimulusLevels(:)),min(stimulusLevels(:))]);
initialParamsGuess(2) = 1;

% The third is the guess rate, which determines the value the
% function takes on at x = 0.  For 2IFC, this should be locked
% at 0.5.
initialParamsGuess(3) = guessRate;

% The fourth parameter is the lapse rate - the asymptotic
% performance at high values of x.  For a perfect subject, this
% would be 0, but sometimes subjects have a "lapse" and get the
% answer wrong even when the stimulus is easy to see.  We can
% search over this, but shouldn't allow it to take on
% unreasonable values.  0.05 as an upper limit isn't crazy.
lapseLimits = [0 0.05];
initialParamsGuess(4) = mean(lapseLimits);
end