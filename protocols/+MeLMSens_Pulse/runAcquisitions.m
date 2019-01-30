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
    while ~abort && ~isempty(block)
        i = randi(numel(block));
        if ~block(i).hasNextTrial()
            block(i) = [];
        else
            [~, abort] = block(i).runNextTrial(oneLight, trialResponseSys);   
        end
    end
    if abort
        fprintf('Acquisition(s) interrupted.\n'); Speak('Acquisition interrupted.',[],230);
    else
        fprintf('Acquisition(s) complete.\n'); Speak('Acquisition complete.',[],230);
    end
end    
    
end

