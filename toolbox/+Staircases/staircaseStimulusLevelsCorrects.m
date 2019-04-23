function [stimulusLevels,correct] = staircaseStimulusLevelsCorrects(staircase)
%% Extract values, correct/incorrect
for k = 1:numel(staircase)
    [values{k}, corrects{k}] = getTrials(staircase(k));
    nTrials(k) = length(values{k});
end
nTrials = min(nTrials);
for k = 1:numel(staircase)
    stimulusLevels(:,k) = values{k}(1:nTrials);
    correct(:,k) = corrects{k}(1:nTrials);
end

correct = logical(correct);
stimulusLevels = round(stimulusLevels,8);
end