function params = OLPsychophysics2IFCLuminanceDetection(exp, params)
% params = OLPsychophysics2IFCPulseConeNoiseFixedContrast(exp)

%% Setup basic parameters for the experiment
params = initParams(exp);

%% Set up timing properties for the event
params.DurationSecsIntervalCosineWindow = 0.25;
tInterval = 0:params.DurationSecsFrame:params.DurationSecsInterval-params.DurationSecsFrame;
NTotal = length(tInterval);
NWindowed = params.DurationSecsIntervalCosineWindow/params.DurationSecsFrame;

%% Set up timing properties for the pre-stimulus and post-stimulus times
tPreStim = 0:params.DurationSecsFrame:params.DurationSecsPreStim-params.DurationSecsFrame;
tPostStim = 0:params.DurationSecsFrame:params.DurationSecsPostStim-params.DurationSecsFrame;
tISIStim = 0:params.DurationSecsFrame:params.DurationSecsISIStim-params.DurationSecsFrame;
tRespInterv = 0:params.DurationSecsFrame:params.DurationSecsResponseInterv-params.DurationSecsFrame;
tTransition = 0:params.DurationSecsFrame:params.DurationSecsCosineWindowBetweenBG-params.DurationSecsFrame;

%% Define the cosine window indices
cosineWindowInIdx = 1:NWindowed;
cosineWindowOutIdx = (NTotal-(NWindowed))+1:NTotal;
cosineWindowIn = ((cos(pi + linspace(0, 1, NWindowed)*pi)+1)/2);
cosineWindowOut = cosineWindowIn(end:-1:1);

cal = LoadCalFile(['OL' params.CalibrationType]);

baseDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/';
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

% Set up the cache.
olCache = OLCache(cacheDir, cal);

% Load the cache data.
cacheBackgroundStimuli = allwords(params.BackgroundStimulusFiles);
cacheFlicker = allwords(params.StimulusFiles);
cacheFlickerData = olCache.load(['Cache-' cacheFlicker{1}]);
for s = 1:params.NStimulusTypes
    cache = olCache.load(['Cache-' cacheBackgroundStimuli{s}]);
    bgPrimary = cache.data(params.observerAge).backgroundPrimary + params.BackgroundPolarity(s)*cache.data(params.observerAge).differencePrimary;
    diffPrimary = cacheFlickerData.data(params.observerAge).differencePrimary;
    basisPrimary{s} = [bgPrimary diffPrimary];
    backgroundLabel{s} = cache.data(params.observerAge).describe.params.backgroundType;
    stimulusLabel{s} = cache.data(params.observerAge).describe.params.modulationDirection;
end


%% Set up sounds
Fs = 8192;
nSeconds = params.DurationSecsInterval; % Leave a little margin
frequencyInterv1 = 440; frequencyInterv2 = 440;
soundInterv1 = 0.8*sin(linspace(0, nSeconds*frequencyInterv1*2*pi, round(nSeconds*Fs)))/2;
audInterv1 = audioplayer(soundInterv1, Fs);
soundInterv2 = 0.8*sin(linspace(0, nSeconds*frequencyInterv2*2*pi, round(nSeconds*Fs)))/2;
audInterv2 = audioplayer(soundInterv2, Fs);
nSeconds = 0.15; frequencyStartTrial = 880;
soundStartTrial = sin(linspace(0, nSeconds*frequencyStartTrial*2*pi, round(nSeconds*Fs)))/2;
audStartTrial = audioplayer(soundStartTrial, Fs);
soundEndTrial = [sin(linspace(0, nSeconds*frequencyStartTrial*2*pi, round(nSeconds*Fs)))/2 ...
    sin(linspace(0, nSeconds*frequencyStartTrial/2*2*pi, round(nSeconds*Fs)))/2];
audEndTrial = audioplayer(soundEndTrial, Fs);
nSeconds = 0.05; frequencyFeedback = 880;
soundFeedback1 = sin(linspace(0, nSeconds*frequencyFeedback*2*pi, round(nSeconds*Fs)))/2;
soundFeedback = [soundFeedback1 zeros(size(soundFeedback1)) soundFeedback1 zeros(size(soundFeedback1)) soundFeedback1];
audFeedback = audioplayer(soundFeedback, Fs);
[buzzer, Fs] = audioread('buzzer.wav', [2000 5000]);
buzzerplayer = audioplayer(buzzer, Fs);
durSecs = 0.025;
t = linspace(0, durSecs, durSecs*Fs);
yHint = [sin(880*2*pi*t)];
audHint = audioplayer(yHint, Fs);

maxContrastFile = 0.05;
maxContrast = maxContrastFile;
minContrast = params.ContrastStep;
params.ContrastLevels = (0:params.ContrastStep:maxContrast)/maxContrastFile;
params.ContrastLevelsReal = (0:params.ContrastStep:maxContrast);
NContrastLevels = length(params.ContrastLevels);
contrastSteps = 1:params.ContrastLevels;
params.NContrastLevels = NContrastLevels;


%% Calculate the transition between backgrounds
NWindowedTransition = length(tTransition);
cosineWindowTransition = ((cos(pi + linspace(0, 1, NWindowedTransition)*pi)+1)/2);

fprintf('*** Calculating transition...');
for p = 1:NWindowedTransition
    %% Calculate transition from OFF to 1 // 1 to OFF
    transitionPrimary(:, p) = cosineWindowTransition(p)*basisPrimary{1}(:, 1);
    transitionSettings(:, p) = OLPrimaryToSettings(cal, transitionPrimary(:, p));
    [transitionStarts(:, p), transitionStops(:, p)] = OLSettingsToStartsStops(cal, transitionSettings(:, p));
    transitionOFFToBG1.starts(:, p) = transitionStarts(:, p);
    transitionOFFToBG1.stops(:, p) = transitionStops(:, p);
    
    % Also reverse
    transitionBG1ToOFF.starts = transitionStarts(:, end:-1:1);
    transitionBG1ToOFF.stops = transitionStops(:, end:-1:1);
    
    %% Calculate transition from OFF to 2 // 2 to OFF
    transitionPrimary(:, p) = cosineWindowTransition(p)*basisPrimary{2}(:, 1);
    transitionSettings(:, p) = OLPrimaryToSettings(cal, transitionPrimary(:, p));
    [transitionStarts(:, p), transitionStops(:, p)] = OLSettingsToStartsStops(cal, transitionSettings(:, p));
    transitionOFFToBG2.starts(:, p) = transitionStarts(:, p);
    transitionOFFToBG2.stops(:, p) = transitionStops(:, p);
    
    % Also reverse
    transitionBG2ToOFF.starts = transitionStarts(:, end:-1:1);
    transitionBG2ToOFF.stops = transitionStops(:, end:-1:1);
    
    %% Calculate transition from OFF to 2 // 2 to OFF
    transitionPrimary(:, p) = cosineWindowTransition(p)*basisPrimary{1}(:, 1) + (1-cosineWindowTransition(p))*basisPrimary{2}(:, 1);
    transitionSettings(:, p) = OLPrimaryToSettings(cal, transitionPrimary(:, p));
    [transitionStarts(:, p), transitionStops(:, p)] = OLSettingsToStartsStops(cal, transitionSettings(:, p));
    transitionBG1ToBG2.starts(:, p) = transitionStarts(:, p);
    transitionBG1ToBG2.stops(:, p) = transitionStops(:, p);
    
    % Also reverse
    transitionBG2ToBG1.starts = transitionStarts(:, end:-1:1);
    transitionBG2ToBG1.stops = transitionStops(:, end:-1:1);
end
fprintf('done.\n');

%% Event objects
fprintf('*** Calculating events...');
for T = 1:params.NStimulusTypes
    for C = 1:params.NContrastLevels
        clear startsBuffer stopsBuffer;
        % Waveform specified for each of the primaries
        s = zeros(size(basisPrimary{T}, 2), NTotal);
        noiseStateVectorLMS = zeros(1, NTotal);
        noiseStateVectorLMinusM = zeros(1, NTotal);
        s(1, :) = 1;                % Background
        s(2, :) = params.ContrastLevels(C)*sin(2*pi*params.FlickerFrequency*tInterval);
        s(2, cosineWindowInIdx) = s(2, cosineWindowInIdx).*cosineWindowIn;
        s(2, cosineWindowOutIdx) = s(2, cosineWindowOutIdx).*cosineWindowOut;
        
        % Calculate the primary settings as a simple linear operation
        primariesBuffer = basisPrimary{T}*s;
        
        for i = 1:size(primariesBuffer, 2)
            primariesBufferT{T, C}(:, i) = OLPrimaryToSpd(cal, primariesBuffer(:, i));
        end
        % Find the unique primary settings up to a tolerance value
        [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
        uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
        
        % Convert the unique primaries to starts and stops
        settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
        for si = 1:size(settingsBuffer, 2)
            [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
        end
        
        eventObj(T, C).IC = IC;
        eventObj(T, C).startsBuffer = startsBuffer;
        eventObj(T, C).stopsBuffer = stopsBuffer;
    end
end
fprintf('done.\n');


%% Blank event object
fprintf('*** Calculating blanks...');
for T = 1:params.NStimulusTypes
    clear startsBuffer stopsBuffer;
    % Waveform specified for each of the primaries
    s = zeros(size(basisPrimary{T}, 2), NTotal);
    noiseStateVectorLMS = zeros(1, NTotal);
    noiseStateVectorLMinusM = zeros(1, NTotal);
    s(1, :) = 1;                % Background
    s(2, :) = 0;
    
    % Calculate the primary settings as a simple linear operation
    primariesBuffer = basisPrimary{T}*s;
    
    for i = 1:size(primariesBuffer, 2)
        primariesBufferT{T}(:, i) = OLPrimaryToSpd(cal, primariesBuffer(:, i));
    end
    % Find the unique primary settings up to a tolerance value
    [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
    uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
    
    % Convert the unique primaries to starts and stops
    settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
    for si = 1:size(settingsBuffer, 2)
        [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
    end
    
    blankObj(T).IC = IC;
    blankObj(T).startsBuffer = startsBuffer;
    blankObj(T).stopsBuffer = stopsBuffer;
end
fprintf('done.\n');

%% Start the experiment
% Make sure that no key presses come to the MATLAB console
% Set up our gamepad object
gamePad = GamePad();

ol = OneLight;
SKIP_ADAPTATION = GetWithDefault('Skip adaptation?', 0);
if ~SKIP_ADAPTATION
    OLAllMirrorsOff;
    system('say -r 230 Press any key to start dark adaptation.');
    
    keepGoing = true;
    while (keepGoing)
        % Read the gamePage
        [action, time] = gamePad.read();
        
        switch (action)
            case gamePad.noChange       % do nothing
                
            case gamePad.buttonChange   % see which button was pressed
                
                if (gamePad.buttonB)
                    keepGoing = false;
                end
        end  % while keepGoing
    end
    
    OLDarkTimer;
end


% Set up the file to save into
fid = fopen(fullfile(exp.subjectDataDir, [params.obsIDAndRun '.csv']), 'w');

%% Background adaptation
for cT = 1:length(params.StimulusOrder)
    % Index of current background
    T = params.StimulusOrder(cT);
    
    %% Show the transition. Assume we're always alternating between backgrounds
    system(['say Block ' num2str(cT) ' of ' num2str(length(params.StimulusOrder)) '.']);
    if (cT == 1)
        switch T
            case 1
                for p = 1:NWindowedTransition
                    ol.setMirrors(transitionOFFToBG1.starts(:, p), transitionOFFToBG1.stops(:, p));
                    mglWaitSecs(params.DurationSecsFrame);
                end
            case 2
                for p = 1:NWindowedTransition
                    ol.setMirrors(transitionOFFToBG2.starts(:, p), transitionOFFToBG2.stops(:, p));
                    mglWaitSecs(params.DurationSecsFrame);
                end
        end
    else
        switch T
            case 1
                for p = 1:NWindowedTransition
                    ol.setMirrors(transitionBG2ToBG1.starts(:, p), transitionBG2ToBG1.stops(:, p));
                    mglWaitSecs(params.DurationSecsFrame);
                end
            case 2
                for p = 1:NWindowedTransition
                    ol.setMirrors(transitionBG1ToBG2.starts(:, p), transitionBG1ToBG2.stops(:, p));
                    mglWaitSecs(params.DurationSecsFrame);
                end
        end
    end
    
    
    % Set the mirrors to the background
    ol.setMirrors(blankObj(T).startsBuffer, blankObj(T).stopsBuffer);
    
    % Inform the participant where we are
    system(['say Press any key to start block.']);
    
    keepGoing = true;
    while (keepGoing)
        % Read the gamePage
        [action, time] = gamePad.read();
        
        switch (action)
            case gamePad.noChange       % do nothing
                
            case gamePad.buttonChange   % see which button was pressed
                
                if (gamePad.buttonB)
                    keepGoing = false;
                end
        end  % while keepGoing
    end
    
    if ~SKIP_ADAPTATION
        % Background adaptation
        system('say -r 230 Press any key to start background adaptation.');
        
        keepGoing = true;
        while (keepGoing)
            % Read the gamePage
            [action, time] = gamePad.read();
            
            switch (action)
                case gamePad.noChange       % do nothing
                    
                case gamePad.buttonChange   % see which button was pressed
                    
                    if (gamePad.buttonB)
                        keepGoing = false;
                    end
            end  % while keepGoing
        end
        system('say -r 240 Adapt to background for 10 minutes');
        mglWaitSecs(60);
        system('say -r 240 9 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 8 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 7 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 6 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 5 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 4 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 3 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 2 minutes left.');
        mglWaitSecs(60);
        system('say -r 240 1 minute left.');
        mglWaitSecs(60);
    end
    system('say -r 240 Adaptation complete. The experiment begins now.');
    
    
    %% PRACTICE TRIALS
    
    %% Set up the staircase. (from psychofitTutorial.m)
    % The code below runs three interleaved staircases.
    %   For 'quest', three different criterion percent correct values are used.
    %   For 'standard', three different up/down rules are used.
    % The use of 3 is hard-coded, in the sense that the vector lengths of the
    % criterion/up-down vectors must match this number.
    
    staircaseType = 'standard';
    % Initialize staircases.  Initialization is slightly different for 'standard'
    % and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
    % are required, and this is enforced by the class constructor function.
    for k = 1:params.NInterleavedStaircases
        stepSizes = [4*params.ContrastStep 2*params.ContrastStep params.ContrastStep];
        nUps = [3 2 1];
        nDowns = [1 1 1];
        initialGuess = params.ContrastLevels(randi(params.NContrastLevels))*maxContrast;
        st{k} = Staircase(staircaseType,initialGuess, ...
            'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
            'MaxValue', maxContrast, 'MinValue', minContrast);
        
        % Set up a vector which tells us which interval we are in
        theIntervals{k} = Shuffle([1*ones(1, params.NTrialsPerStaircase) 2*ones(1, params.NTrialsPerStaircase)]);
    end
    
    % Set up the break trials
    NTrials = params.NInterleavedStaircases*params.NTrialsPerStaircase;
    breakTrials = 0:params.BreakTrialInterval:NTrials;
    breakTrials(end) = []; breakTrials(1) = [];
    
    F = 1;
    counter = 1;
    % Run interleaved staircases
    for st1 = 1:params.NTrialsPerStaircase
        order = Shuffle(1:params.NInterleavedStaircases);
        for k = 1:params.NInterleavedStaircases
            % Get the contrast
            testContrast = getCurrentValue(st{order(k)});
            if find(breakTrials == counter)
                system(['say Trial ' num2str(counter) ' of ' num2str(NTrials) ' in this block. Take a break, press any key to continue.']);
                
                keepGoing = true;
                while (keepGoing)
                    % Read the gamePage
                    [action, time] = gamePad.read();
                    
                    switch (action)
                        case gamePad.noChange       % do nothing
                            
                        case gamePad.buttonChange   % see which button was pressed
                            
                            if (gamePad.buttonB)
                                keepGoing = false;
                            end
                    end  % while keepGoing
                end
            end
            %testContrast
            % Assemble the information needed for the trial
            % Find the index of the test contrast in our contrast
            % vector.
            [~, C] = min(abs(params.ContrastLevelsReal - testContrast));
            StimFirstOrSecond = theIntervals{k}(st1);
            
            timeStamp = datestr(now);
            clear sound;
            
            %% Pre-stimulus intervals
            play(audStartTrial);
            ol.setMirrors(blankObj(T).startsBuffer, blankObj(T).stopsBuffer)
            mglWaitSecs(params.DurationSecsPreStim);
            %tic
            %% Stimulus 1
            play(audInterv1); % Play sound
            if StimFirstOrSecond == 1
                mileStone = mglGetSecs + params.DurationSecsFrame;
                i = 0;
                while i+1 <= length(eventObj(T, C).IC)
                    if mglGetSecs >= mileStone;
                        i = i+1;
                        mileStone = mglGetSecs + params.DurationSecsFrame;
                        ol.setMirrors(eventObj(T, C).startsBuffer(:, eventObj(T, C).IC(i)), eventObj(T, C).stopsBuffer(:, eventObj(T, C).IC(i)));
                    end
                end
            elseif StimFirstOrSecond == 2
                mileStone = mglGetSecs + params.DurationSecsFrame;
                i = 0;
                while i+1 <= length(blankObj(T).IC)
                    if mglGetSecs >= mileStone;
                        i = i+1;
                        mileStone = mglGetSecs + params.DurationSecsFrame;
                        ol.setMirrors(blankObj(T).startsBuffer(:, blankObj(T).IC(i)), blankObj(T).stopsBuffer(:, blankObj(T).IC(i)));
                    end
                end
            end
            %toc
            %% Inter-stimulus intervals
            ol.setMirrors(blankObj(T).startsBuffer, blankObj(T).stopsBuffer)
            mglWaitSecs(params.DurationSecsISIStim);
            
            play(audInterv2); % Play sound
            %tic
            %% Stimulus 2
            if StimFirstOrSecond == 1
                mileStone = mglGetSecs + params.DurationSecsFrame;
                i = 0;
                while  i+1 <= length(blankObj(T).IC)
                    if mglGetSecs >= mileStone;
                        i = i+1;
                        mileStone = mglGetSecs + params.DurationSecsFrame;
                        ol.setMirrors(blankObj(T).startsBuffer(:, blankObj(T).IC(i)), blankObj(T).stopsBuffer(:, blankObj(T).IC(i)));
                    end
                end
            elseif StimFirstOrSecond == 2
                mileStone = mglGetSecs + params.DurationSecsFrame;
                i = 0;
                while  i+1 <= length(eventObj(T, C).IC)
                    if mglGetSecs >= mileStone;
                        i = i+1;
                        mileStone = mglGetSecs + params.DurationSecsFrame;
                        ol.setMirrors(eventObj(T, C).startsBuffer(:, eventObj(T, C).IC(i)), eventObj(T, C).stopsBuffer(:, eventObj(T, C).IC(i)));
                    end
                end
            end
            %toc
            %% Post-stimulus intervals
            mglGetKeyEvent;
            ol.setMirrors(blankObj(T).startsBuffer, blankObj(T).stopsBuffer)
            mglWaitSecs(params.DurationSecsPostStim);
            
            %% Response interval
            play(audEndTrial);
            ol.setMirrors(blankObj(T).startsBuffer, blankObj(T).stopsBuffer);
            
            keepRunning = true;
            t0 = mglGetSecs;
            while and((t0+params.DurationSecsResponseInterv > mglGetSecs), keepRunning);
                action = gamePad.read();
                switch (action)
                    case gamePad.noChange       % do nothing
                        response(counter) = NaN;
                    case gamePad.buttonChange   % see which button was pressed
                        % Trigger buttons
                        if (gamePad.buttonLeftUpperTrigger) ||  (gamePad.buttonLeftLowerTrigger)
                            response(counter) = 1;
                            play(audHint);
                            keepRunning = false;
                        elseif (gamePad.buttonRightUpperTrigger) || (gamePad.buttonRightLowerTrigger)
                            response(counter) = 2;
                            play(audHint);
                            keepRunning = false;
                        end
                end
                if response(counter) == StimFirstOrSecond
                    correctOrNot = 1;
                else
                    correctOrNot = 0;
                end
            end
            stop(audHint);
            
            fprintf('%s: Trial %g in staircase %g, contrast %.2f (idx %g), correct? %g\n', timeStamp, counter, order(k), testContrast, C, correctOrNot);
            fprintf(fid, '%s,%s,%g,%g,%g,%s,%s,%.4f,%g,%g,%g,%g\n', timeStamp, params.obsID, counter, order(k), params.StimulusOrder(cT), backgroundLabel{T}, stimulusLabel{T}, testContrast, C, StimFirstOrSecond, response(counter), correctOrNot);
            % Update. 1 = correct; 0 = incorrect
            st{order(k)} = updateForTrial(st{order(k)}, testContrast, correctOrNot);
            
            stop(audEndTrial); stop(audInterv1); stop(audInterv2); stop(audStartTrial);
            % Update the counter
            counter = counter+1;
        end
        
    end
    system('say Block finished.');
end
fclose(fid);
system('say Experiment finished. You are now a free man.');

function params = initParams(exp)
% params = initParams(exp)
% Initialize the parameters

[~, tmp, suff] = fileparts(exp.configFileName);
exp.configFileName = fullfile(exp.configFileDir, [tmp, suff]);

% Load the config file for this condition.
cfgFile = ConfigFile(exp.configFileName);

% Convert all the ConfigFile parameters into simple struct values.
params = convertToStruct(cfgFile);
params.cacheDir = fullfile(fileparts(which('OLFlickerSensitivity')), 'cache');

% Load the calibration file.
cType = OLCalibrationTypes.(params.CalibrationType);
params.oneLightCal = LoadCalFile(cType.CalFileName);

% Setup the cache.
params.olCache = OLCache(params.cacheDir, params.oneLightCal);

file_names = allwords(params.StimulusFiles,',');
for i = 1:length(file_names)
    % Create the cache file name.
    [~, params.cacheFileName{i}] = fileparts(file_names{i});
end
params.protocolName = exp.protocolList(exp.protocolIndex).dataDirectory;
params.obsIDAndRun = exp.obsIDAndRun;
params.obsID = exp.subject;
params.nullingID = exp.nullingID;
params.observerAge = exp.observerAge;