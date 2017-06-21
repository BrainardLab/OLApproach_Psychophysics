% MaxPulsePsychophysics_Analysis.m
%
% Analyses rating data. Hacked up for now.
%
% 11/22/16  spitschan  Wrote it.
% 02/09/2017 JR proposed edits: Plot of average ratings across subjects
% with standard error bars; Histogram of each rating value (1 -7) across subjects for each
% perceptual dimension for each trial (1-3). This would be a figure with 3
% bar plots in it containing the number of times subjects responded 1-7 for
% each dimension.


%% Individual Plots

% Subject information:
observerID = GetWithDefault('>> Enter <strong> subject ID </strong>', 'MELA_xxxx');
expDate = GetWithDefault('>> Enter <strong>experiment date</strong>', '010116');

% Load the file
dataPath = getpref('OneLight', 'dataPath');
protocol = 'MaxPulsePsychophysics';
load(fullfile(dataPath, protocol, observerID, expDate, 'MatFiles',[observerID '-' protocol '.mat'])); 
% Get all the stimulus types
allLabels = {data.stimLabel};
[uniqueLabels, ~, allLabelsIdx] = unique(allLabels);

% Get all the perceptual dimensions
allDimensions = {data.perceptualDimension};
[uniqueDimensions, ~, allDimensionsIdx] = unique(allDimensions);

% Assemble all responses
allResponses = [data.response];

% Iterate over stimulus types and perceptual rating dimensions
for ii = 1:length(uniqueLabels)
   for jj = 1:length(uniqueDimensions)
      % Find the trials that correspond to this
      aggregatedData{ii, jj} = allResponses((allLabelsIdx == ii) & (allDimensionsIdx == jj));
      aggregatedDataMean(ii, jj) = mean(allResponses((allLabelsIdx == ii) & (allDimensionsIdx == jj)));
   end
end

% Make a bar plot of the mean ratings
h = bar(aggregatedDataMean');
set(gca, 'XTickLabel', uniqueDimensions);
legend(h, uniqueLabels);
ylim([0 7]);

%% Average Plot

% Set up:
observers = {'MELA_0049'; 'MELA_0050'; 'MELA_0075'; 'MELA_0077'};
expDate = {'020317', '020717', '020617', '020817'};
dataPath = getpref('OneLight', 'dataPath');
protocol = 'MaxPulsePsychophysics';

% Loop over subjects:
for i = length(observers)
    load(fullfile(dataPath, protocol, char(observers(i)), char(expDate(i)), 'MatFiles',[char(observers(i)) '-' protocol '.mat'])); 
    
    % Get all the stimulus types
    allLabels = {data.stimLabel};
    [uniqueLabels, ~, allLabelsIdx] = unique(allLabels);
    
    % Get all the perceptual dimensions
    allDimensions = {data.perceptualDimension};
    [uniqueDimensions, ~, allDimensionsIdx] = unique(allDimensions);
    
    % Assemble all responses for this subject
    subjectResponses = [data.response];
    allResponses = [
    
end 

