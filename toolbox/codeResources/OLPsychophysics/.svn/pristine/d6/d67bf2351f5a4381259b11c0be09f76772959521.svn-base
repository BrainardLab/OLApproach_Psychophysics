function params = OLPsychophysics2IFCPulseConeNoiseFixedContrast(exp, params)
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
cacheModulation = allwords(params.StimulusModulationTypes);
cacheBackgroundShift = allwords(params.BackgroundShiftTypes);
cacheModulation1 = olCache.load(['Cache-' cacheModulation{1}]);
cacheBackgroundShift1 = olCache.load(['Cache-' cacheBackgroundShift{1}]);

% Load in primary values
bgPrimary = cacheModulation1.data(32).backgroundPrimary;
diffPrimaryBackgroundShift = cacheBackgroundShift1.data(32).modulationPrimarySignedPositive-cacheBackgroundShift1.data(32).backgroundPrimary;
diffPrimary = cacheModulation1.data(32).modulationPrimarySignedPositive-cacheModulation1.data(32).backgroundPrimary;
basisPrimary{1} = [bgPrimary diffPrimary diffPrimaryBackgroundShift];


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


contrastStep = 0.005;
maxContrastFile = 0.05;
maxContrast = maxContrastFile;
minContrast = contrastStep;
contrastLevels = (0:contrastStep:maxContrast)/maxContrastFile;
contrastSteps = 1:length(contrastLevels);
NContrastLevels = length(contrastSteps);
%contrastLevels = linspace(0, 1, params.NContrastLevels);
params.NContrastLevels = NContrastLevels;

%% Event objects
fprintf('*** Calculating events...');
for T = 1:params.NTrialTypes
    for F = 1:params.NFrequencies
        for C = 1:params.NContrastLevels
            clear startsBuffer stopsBuffer;
            % Waveform specified for each of the primaries
            s = zeros(size(basisPrimary{T}, 2), NTotal);
            noiseStateVectorLMS = zeros(1, NTotal);
            noiseStateVectorLMinusM = zeros(1, NTotal);
            s(1, :) = 1;                % Background
            s(2, :) = sin(2*pi*params.frequencies(F)*tInterval);
            
            % Assign the background shift vector
            s(3, :) = contrastLevels(C);
            
            % Calculate the primary settings as a simple linear operation
            primariesBuffer = basisPrimary{T}*s;
            
            for i = 1:size(primariesBuffer, 2)
                primariesBufferT{T, F, C}(:, i) = OLPrimaryToSpd(cal, primariesBuffer(:, i));
            end
            % Find the unique primary settings up to a tolerance value
            [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
            uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
            
            % Convert the unique primaries to starts and stops
            settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
            for si = 1:size(settingsBuffer, 2)
                [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
            end
            
            eventObj(T, F, C).IC = IC;
            eventObj(T, F, C).startsBuffer = startsBuffer;
            eventObj(T, F, C).stopsBuffer = stopsBuffer;
        end
    end
end
fprintf('done.\n');

%% Blank event object
fprintf('*** Calculating blanks...');
for T = 1:params.NTrialTypes
    for F = 1:params.NFrequencies
        clear startsBuffer stopsBuffer;
        % Waveform specified for each of the primaries
        s = zeros(size(basisPrimary{T}, 2), NTotal);
        noiseStateVectorLMS = zeros(1, NTotal);
        noiseStateVectorLMinusM = zeros(1, NTotal);
        s(1, :) = 1;                % Background
        s(2, :) = sin(2*pi*params.frequencies(F)*tInterval);
        
        % Assign the background shift vector
        s(3, :) = 0;
        
        % Calculate the primary settings as a simple linear operation
        primariesBuffer = basisPrimary{T}*s;
        
        for i = 1:size(primariesBuffer, 2)
            primariesBufferT{T, F}(:, i) = OLPrimaryToSpd(cal, primariesBuffer(:, i));
        end
        % Find the unique primary settings up to a tolerance value
        [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
        uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
        
        % Convert the unique primaries to starts and stops
        settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
        for si = 1:size(settingsBuffer, 2)
            [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
        end
        
        blankObj(T, F).IC = IC;
        blankObj(T, F).startsBuffer = startsBuffer;
        blankObj(T, F).stopsBuffer = stopsBuffer;
    end
end
fprintf('done.\n');

%% Background calculations
fprintf('*** Calculating background...');
for T = [1:4]
    for F = 1:params.NFrequencies
        switch T
            case 1
                NTotal = length(tPreStim);
                tHere = tPreStim;
            case 2
                NTotal = length(tISIStim);
                tHere = tISIStim;
            case 3
                NTotal = length(tPostStim);
                tHere = tPostStim;
            case 4
                NTotal = length(tRespInterv);
                tHere = tRespInterv;
        end
        clear startsBuffer stopsBuffer;
        
        % Waveform size specified for each of the primaries
        s = zeros(size(basisPrimary{1}, 2), NTotal);
        noiseStateVectorLMS = zeros(1, NTotal);
        noiseStateVectorLMinusM = zeros(1, NTotal);
        s(1, :) = 1;    % Background
        s(2, :) = sin(2*pi*params.frequencies(F)*tHere);    % Modulation
        
        s(3, :) = 0;
        % Calculate the primary settings as a simple linear operation
        primariesBuffer = basisPrimary{1}*s;
        
        % Find the unique primary settings up to a tolerance value
        %[uniqPrimariesBuffer, ~, IC] = uniquetol(primariesBuffer', 'ByRows', true);
        [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
        uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
        
        % Convert the unique primaries to starts and stops
        settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
        for si = 1:size(settingsBuffer, 2)
            [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
        end
        
        switch T
            case 1
                backgroundPreStimObj(F).IC = IC;
                backgroundPreStimObj(F).startsBuffer = startsBuffer;
                backgroundPreStimObj(F).stopsBuffer = stopsBuffer;
            case 2
                backgroundISIStimObj(F).IC = IC;
                backgroundISIStimObj(F).startsBuffer = startsBuffer;
                backgroundISIStimObj(F).stopsBuffer = stopsBuffer;
            case 3
                backgroundPostStimObj(F).IC = IC;
                backgroundPostStimObj(F).startsBuffer = startsBuffer;
                backgroundPostStimObj(F).stopsBuffer = stopsBuffer;
            case 4
                backgroundRespIntervObj(F).IC = IC;
                backgroundRespIntervObj(F).startsBuffer = startsBuffer;
                backgroundRespIntervObj(F).stopsBuffer = stopsBuffer;
        end
    end
end
fprintf('done.\n');


%% The trial vector
trialLogic = 1:5;

ol = OneLight;
% Make sure that no key presses come to the MATLAB console
mglListener(7, ['1' '6' 'z']);
%OLAllMirrorsOff; OLDarkTimer;
settings = OLPrimaryToSettings(cal, bgPrimary);
[starts, stops] = OLSettingsToStartsStops(cal, settings);
ol.setMirrors(starts, stops);
% system('say -r 230 Press any key to start.');
% pause;
% system('say -r 210 Adapt to background for five minutes');
% mglWaitSecs(60);
% system('say -r 210 4 minutes left.');
% mglWaitSecs(60);
% system('say -r 210 3 minutes left.');
% mglWaitSecs(60);
% system('say -r 210 2 minutes left.');
% mglWaitSecs(60);
% system('say -r 210 1 minute left.');
% mglWaitSecs(60);
% system('say -r 210 Adaptation complete. The experiment begins now.');

fid = fopen(['~/Desktop/' params.obsIDAndRun '.csv'], 'w');

%% PRACTICE TRIALS

%% Set up the staircase. (from psychofitTutorial.m)
% The code below runs three interleaved staircases.
%   For 'quest', three different criterion percent correct values are used.
%   For 'standard', three different up/down rules are used.
% The use of 3 is hard-coded, in the sense that the vector lengths of the
% criterion/up-down vectors must match this number.
NTrialsPerStaircase = 40;

staircaseType = 'standard';
% Initialize staircases.  Initialization is slightly different for 'standard'
% and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
% are required, and this is enforced by the class constructor function.
NInterleavedStaircases = 3;
for k = 1:NInterleavedStaircases
    stepSizes = [4*contrastStep 2*contrastStep contrastStep];
    nUps = [3 2 1];
    nDowns = [1 1 1];
    initialGuess = contrastLevels(randi(params.NContrastLevels))*maxContrast;
    st{k} = Staircase(staircaseType,initialGuess, ...
        'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
        'MaxValue', maxContrast, 'MinValue', minContrast);
    
    % Set up a vector which tells us which interval we are in
    theIntervals{k} = Shuffle([1*ones(1, NTrialsPerStaircase) 2*ones(1, NTrialsPerStaircase)]);
end

% Set up the break trials
NTrials = NInterleavedStaircases*NTrialsPerStaircase;

F = 1;
counter = 1;
% Run interleaved staircases
for st1 = 1:NTrialsPerStaircase
    order = Shuffle(1:NInterleavedStaircases);
    for k = 1:NInterleavedStaircases
        % Get the contrast
        testContrast = getCurrentValue(st{order(k)});
        
        % Assemble the information needed for the trial
        % Find the index of the test contrast in our contrast
        % vector.
        [~, C] = min(abs(contrastLevels*maxContrast - testContrast));
        intval = theIntervals{k}(st1);
        
        timeStamp = datestr(now);
        clear sound;
        % Run the trials
        
        for m = 1:length(trialLogic)
            switch trialLogic(m)
                case 1
                    % Pre-stimulus background
                    startsBuffer = backgroundPreStimObj(F).startsBuffer;
                    stopsBuffer = backgroundPreStimObj(F).stopsBuffer;
                    IC = backgroundPreStimObj(F).IC;
                case 2
                    % Interval 1
                    T = 1;
                    if intval == 1
                        startsBuffer = eventObj(T, F, C).startsBuffer;
                        stopsBuffer = eventObj(T, F, C).stopsBuffer;
                        IC = eventObj(T, F, C).IC;
                    elseif intval == 2
                        startsBuffer = blankObj(T, F).startsBuffer;
                        stopsBuffer = blankObj(T, F).stopsBuffer;
                        IC = blankObj(T, F).IC;
                    end
                case 3
                    % Inter-stimulus background
                    startsBuffer = backgroundISIStimObj(F).startsBuffer;
                    stopsBuffer = backgroundISIStimObj(F).stopsBuffer;
                    IC = backgroundISIStimObj(F).IC;
                case 4
                    % Interval 2
                    T = 1;
                    if intval == 1
                        startsBuffer = blankObj(F).startsBuffer;
                        stopsBuffer = blankObj(F).stopsBuffer;
                        IC = blankObj(F).IC;
                    elseif intval == 2
                        startsBuffer = eventObj(T, F, C).startsBuffer;
                        stopsBuffer = eventObj(T, F, C).stopsBuffer;
                        IC = eventObj(T, F, C).IC;
                    end
                case 5
                    % Post-stimulus background
                    startsBuffer = backgroundPostStimObj(F).startsBuffer;
                    stopsBuffer = backgroundPostStimObj(F).stopsBuffer;
                    IC = backgroundPostStimObj(F).IC;
            end
            
            %% Play the sounds
            switch trialLogic(m)
                case 1
                    play(audStartTrial);
                case 2
                    play(audInterv1); % Play sound
                case 4
                    play(audInterv2); % Play sound
            end
            
            %% Show the stimulus
            mileStone = mglGetSecs + params.DurationSecsFrame;
            i = 0;
            while i+1 <= length(IC)
                if mglGetSecs >= mileStone;
                    i = i+1;
                    mileStone = mglGetSecs + params.DurationSecsFrame;
                    ol.setMirrors(startsBuffer(:, IC(i)), stopsBuffer(:, IC(i)));
                end
            end
        end
        mglGetKeyEvent;
        
        %% Response interval
        play(audEndTrial);
        
        %tic
        mileStone = mglGetSecs + params.DurationSecsFrame;
        i = 0;
        while i+1 <= length(backgroundRespIntervObj(F).IC)
            if mglGetSecs >= mileStone;
                i = i+1;
                mileStone = mglGetSecs + params.DurationSecsFrame;
                ol.setMirrors(backgroundRespIntervObj(F).startsBuffer(:, backgroundRespIntervObj(F).IC(i)), backgroundRespIntervObj(F).stopsBuffer(:, backgroundRespIntervObj(F).IC(i)));
            end
        end
        %toc
        
        keyEvent = mglGetKeyEvent;
        if isempty(keyEvent)
            response(counter) = NaN;
            %playblocking(buzzerplayer);
        else
            if (str2double(keyEvent.charCode) == 1) || (str2double(keyEvent.charCode) == 2)
                response(counter) = 1;
            elseif (str2double(keyEvent.charCode) == 6) || (str2double(keyEvent.charCode) == 5)
                response(counter) = 2;
            else
                response(counter) = NaN;
            end
            %playblocking(buzzerplayer);
        end
        if response(counter) == intval
            correctOrNot = 1;
        else
            correctOrNot = 0;
        end
        
        stop(audEndTrial);
        stop(audInterv1); % Stop sound
        stop(audInterv2); % Stop sound
        stop(audStartTrial);
        %fprintf(fid, '%s,%s,%s,%g,%g,%g,%g,%g\n', timeStamp, params.obsID,  tmp.nullingaverages{trialVector(idxVector(k))}.direction{1}, k, idxVector(k), trialVector(idxVector(k)), StimFirstOrSecond(idxVector(k)), response(k));
        % Update. 1 = correct; 0 = incorrect
        st{order(k)} = updateForTrial(st{order(k)}, testContrast, correctOrNot);

        % Update the counter
        counter = counter+1;
    end
end
fclose(fid);

% Calculate quick result
uniqueTrialTypes = unique(trialVector);
fid = fopen(['~/Desktop/' params.obsIDAndRun '-summary.csv'], 'w');
for i = 1:length(uniqueTrialTypes)
    idx = find(trialVector == uniqueTrialTypes(i) & ~isnan(response));
    propCorrect(i) = sum(response(idx) == StimFirstOrSecond(idx))/length(idx);
    fprintf(fid, '%g,%g,%g\n', uniqueTrialTypes(i), sum(response(idx) == StimFirstOrSecond(idx)), length(idx))
end
fclose(fid);
system('say Block finished.');

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

file_names = allwords(params.StimulusModulationTypes,',');
for i = 1:length(file_names)
    % Create the cache file name.
    [~, params.cacheFileName{i}] = fileparts(file_names{i});
end
params.protocolName = exp.protocolList(exp.protocolIndex).dataDirectory;
params.obsIDAndRun = exp.obsIDAndRun;
params.obsID = exp.subject;
params.nullingID = exp.nullingID;