function acquisitions = runAcquisitions(acquisitions, oneLight, trialResponseSys)
%RUNACQUISITIONS Summary of this function goes here
%   Detailed explanation goes here

% acquisitions is a matrix: all acquisitions in a single column get
% intermixed (i.e., randomly draw a trial from any acquisition in a column,
% until all are done), while separate columns get 'blocked'.

% Run
for block = acquisitions % loop over columns
    fprintf('Running acquisition(s)...\n')
    
    abort = false;
    [progressTotal, progress] = getBlockProgress(block);
    remainingAcquisitions = block(progress < 1);
    while ~abort && progressTotal < 1
        % Draw random acquisition from remainingAcquisitions
        i = randi(numel(remainingAcquisitions));
        
        % Run trial
        [~, abort] = remainingAcquisitions(i).runNextTrial(oneLight, trialResponseSys);   
        
        % Determine new block progress
        [progressTotal, progress, NTrialsRemaining] = getBlockProgress(block);
        
        % Print block progress
        fprintf('Block progress %.1f%% ([',progressTotal*100);
        fprintf('%.1f%% ', progress*100);
        fprintf(']): %.0f trials remaining\n',sum(NTrialsRemaining));
    end
    if abort
        fprintf('Acquisitions interrupted.\n'); Speak('Acquisitions interrupted.',[],230);
        return;
    else
        fprintf('Block complete.\n'); Speak('Block complete.',[],230);        
    end
end    
fprintf('All acquisitions complete.\n'); Speak('All acquisitions complete.',[],230);
    
end

function [progressTotal, progress, NTrialsRemaining] = getBlockProgress(block)
    NTrials = [];
    NTrialsRemaining = [];
    for acquisition = block'
        NTrials = [NTrials acquisition.NTrialsPerStaircase * acquisition.NInterleavedStaircases];
        NTrialsRemaining = [NTrialsRemaining sum(acquisition.nTrialsRemaining)];
    end
    progress = 1-(NTrialsRemaining./NTrials);
    progressTotal = mean(progress);
end

