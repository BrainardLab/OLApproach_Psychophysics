%%Analysis  Analyses for MaxMelPulsePsychophysics protocol
%
% Description
%     Simple analysis for MaxMelPulsePsychophysics protocol
%
%     The status of this routine is uncertain.  For sure, has not been
%     updated to read data from approach/protocol specific place.  

% 11/22/16  spitschan  Wrote it.

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

