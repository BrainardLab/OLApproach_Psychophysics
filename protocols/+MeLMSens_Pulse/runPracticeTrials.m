function trials = runPracticeTrials(directions, receptors, oneLight, trialResponseSys)
% Run practice trials with(out) mel pulse, and decreasing flicker contrast

%% Make practice trials
trials = makePracticeTrials(directions, receptors);

%% Run trials
for t = trials
    t.run(oneLight, 200, trialResponseSys);
end

end

function trials = makePracticeTrials(directions, receptors)
% Make practice trials with(out) mel pulse, and decreasing flicker contrast

%% Unpack directions
background = directions('Mel_low');
pedestalDirection = directions('MelStep');
flickerDirection(1) = directions('FlickerDirection_Mel_low');
flickerDirection(2) = directions('FlickerDirection_Mel_high');

%% Make trials
% Trials with and without mel pulse
% Vary flicker contrast max:-1:0% contrast
trials = [];
for pedestalPresent = [0 1]
    for flickerContrast = .05:-.01:0
        trial = MeLMSens_Pulse.assembleTrial(background,pedestalDirection,flickerDirection(pedestalPresent+1),pedestalPresent,flickerContrast,receptors);
        trials = [trials trial];
    end
end
    
end