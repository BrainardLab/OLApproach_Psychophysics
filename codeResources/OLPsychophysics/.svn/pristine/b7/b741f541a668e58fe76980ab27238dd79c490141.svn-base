function params = OLPsychophysics2IFCPulseConeNoiseStaircaseNoise(exp, params)
% params = OLPsychophysics2IFCPulseConeNoiseStaircaseNoise(exp)

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

% if ~isempty(params.nullingID) % When no nulling ID is given
%     % Load the cache data.
%     cacheNoise = allwords(params.NoiseModulationTypes); % Get the noise first
%     cacheNoise1 = olCache.load(['Cache-' cacheNoise{1}]);
%     cacheNoise2 = olCache.load(['Cache-' cacheNoise{2}]);
%     
%     % Load in the nulling values
%     nullingBaseDir = '/Users/melanopsin/Dropbox (Aguirre-Brainard Lab)/MELA_data/OLPsychophysicsNulling';
%     tmp = load(fullfile(nullingBaseDir, params.nullingID, [params.nullingID '-nulling-1.mat']));
%     bgPrimary = tmp.nullingaverages{1}.backgroundPrimary;
%     diffPrimary1 = tmp.nullingaverages{1}.differencePrimary;
%     diffPrimary2 = tmp.nullingaverages{2}.differencePrimary;
%     
%     % Also extract observer age
%     observerAgeInYrs = tmp.nulling{1}.observerAgeInYrs;
%     noisePrimary1 = params.NoiseModulationContrast(1)*(cacheNoise1.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheNoise1.data(observerAgeInYrs).backgroundPrimary);
%     noisePrimary2 = params.NoiseModulationContrast(2)*(cacheNoise2.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheNoise2.data(observerAgeInYrs).backgroundPrimary);
%     basisPrimary{1} = [bgPrimary diffPrimary1 noisePrimary1 noisePrimary2];
%     basisPrimary{2} = [bgPrimary diffPrimary2 noisePrimary1 noisePrimary2];
% else  % When no nulling ID is given
    % Load the cache data.
    cacheModulation = allwords(params.StimulusModulationTypes);
    cacheNoise = allwords(params.NoiseModulationTypes);
    cacheModulation1 = olCache.load(['Cache-' cacheModulation{1}]);
    %cacheModulation2 = olCache.load(['Cache-' cacheModulation{2}]);
    cacheNoise1 = olCache.load(['Cache-' cacheNoise{1}]);
    cacheNoise2 = olCache.load(['Cache-' cacheNoise{2}]);
    
    % Load in primary values
    bgPrimary = cacheModulation1.data(32).backgroundPrimary;
    diffPrimary1 = cacheModulation1.data(32).modulationPrimarySignedPositive-cacheModulation1.data(32).backgroundPrimary;
    %diffPrimary2 = cacheModulation2.data(32).modulationPrimarySignedPositive-cacheModulation2.data(32).backgroundPrimary;;
    noisePrimary1 = params.NoiseModulationContrast(1)*(cacheNoise1.data(32).modulationPrimarySignedPositive-cacheNoise1.data(32).backgroundPrimary);
    noisePrimary2 = params.NoiseModulationContrast(2)*(cacheNoise2.data(32).modulationPrimarySignedPositive-cacheNoise2.data(32).backgroundPrimary);
    basisPrimary{1} = [bgPrimary diffPrimary1 noisePrimary1 noisePrimary2];
    %basisPrimary{2} = [bgPrimary diffPrimary2 noisePrimary1 noisePrimary2];
%end



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
maxContrastFile = 0.03;
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
    for C = 1:params.NContrastLevels
        for v = 1:params.NVersionsPerStimulusType
            clear startsBuffer stopsBuffer;
            % Waveform specified for each of the primaries
            s = zeros(size(basisPrimary{T}, 2), NTotal);
            noiseStateVectorLMS = zeros(1, NTotal);
            noiseStateVectorLMinusM = zeros(1, NTotal);
            s(1, :) = 1;                % Background
            s(2, :) = params.StimulusModulationContrast(T);  % Modulation
            s(2, cosineWindowInIdx) = params.StimulusModulationContrast(T)*cosineWindowIn;
            s(2, cosineWindowOutIdx) = params.StimulusModulationContrast(T)*cosineWindowOut;
            
            % Noise
            startIdx = 1:(1/(params.DurationSecsFrame)/(params.NoiseModulationFrequencyHz)):NTotal;
            endIdx = (1/(params.DurationSecsFrame))/(params.NoiseModulationFrequencyHz):(1/(params.DurationSecsFrame))/(params.NoiseModulationFrequencyHz):NTotal;
            DiscreteNoiseLevels = linspace(-1, 1, params.NoiseModulationDiscreteStates);
            
            for i = 1:length(startIdx)
                noiseStateVectorLMS(startIdx(i):endIdx(i)) = DiscreteNoiseLevels(randi(params.NoiseModulationDiscreteStates, 1));
                noiseStateVectorLMinusM(startIdx(i):endIdx(i)) =  DiscreteNoiseLevels(randi(params.NoiseModulationDiscreteStates, 1));
            end
            
            % Assign the noise vector
            s(3, :) = contrastLevels(C)*noiseStateVectorLMS;
            s(4, :) = contrastLevels(C)*noiseStateVectorLMinusM;
            
            % Calculate the primary settings as a simple linear operation
            primariesBuffer = basisPrimary{T}*s;
            %primariesBuffer = basisPrimary{T}(:, [1 2])*s([1 2], :);
            
            for i = 1:size(primariesBuffer, 2)
                primariesBufferT{v, T, C}(:, i) = OLPrimaryToSpd(cal, primariesBuffer(:, i));
            end
            % Find the unique primary settings up to a tolerance value
            %[uniqPrimariesBuffer, ~, IC] = uniquetol(primariesBuffer', 'ByRows', true);
            [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
            uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
            
            % Convert the unique primaries to starts and stops
            settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
            for si = 1:size(settingsBuffer, 2)
                [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
            end
            
            eventObj(v, T, C).IC = IC;
            eventObj(v, T, C).startsBuffer = startsBuffer;
            eventObj(v, T, C).stopsBuffer = stopsBuffer;
        end
    end
end
fprintf('done.\n');

%% Blank event object
fprintf('*** Calculating blanks...');
for v = 1:params.NVersionsPerStimulusType
    for C = 1:params.NContrastLevels
    clear startsBuffer stopsBuffer;
    % Waveform specified for each of the primaries
    s = zeros(size(basisPrimary{1}, 2), NTotal);
    noiseStateVectorLMS = zeros(1, NTotal);
    noiseStateVectorLMinusM = zeros(1, NTotal);
    s(1, :) = 1;                % Background
    s(2, :) = 0;    % Modulation
    
    % Noise
    startIdx = 1:(1/(params.DurationSecsFrame)/(params.NoiseModulationFrequencyHz)):NTotal;
    endIdx = (1/(params.DurationSecsFrame))/(params.NoiseModulationFrequencyHz):(1/(params.DurationSecsFrame))/(params.NoiseModulationFrequencyHz):NTotal;
    DiscreteNoiseLevels = linspace(-1, 1, params.NoiseModulationDiscreteStates);
    
    for i = 1:length(startIdx)
        noiseStateVectorLMS(startIdx(i):endIdx(i)) = DiscreteNoiseLevels(randi(params.NoiseModulationDiscreteStates, 1));
        noiseStateVectorLMinusM(startIdx(i):endIdx(i)) =  DiscreteNoiseLevels(randi(params.NoiseModulationDiscreteStates, 1));
    end
    
    % Assign the noise vector
    s(3, :) = contrastLevels(C)*noiseStateVectorLMS;
    s(4, :) = contrastLevels(C)*noiseStateVectorLMinusM;
    
    % Calculate the primary settings as a simple linear operation
    primariesBuffer = basisPrimary{1}*s;
    %primariesBuffer = basisPrimary{1}(:, [1 2])*s([1 2], :);
    
    % Find the unique primary settings up to a tolerance value
    %[uniqPrimariesBuffer, ~, IC] = uniquetol(primariesBuffer', 'ByRows', true);
    [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
    uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
    
    % Convert the unique primaries to starts and stops
    settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
    for si = 1:size(settingsBuffer, 2)
        [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
    end
    
    blankObj(v, C).IC = IC;
    blankObj(v, C).startsBuffer = startsBuffer;
    blankObj(v, C).stopsBuffer = stopsBuffer;
    end
end
fprintf('done.\n');

%% Background calculations
fprintf('*** Calculating background...');
for T = [1:4]
    for C = 1:params.NContrastLevels
        for v = 1:params.NVersionsPerStimulusType
            switch T
                case 1
                    NTotal = length(tPreStim);
                case 2
                    NTotal = length(tISIStim);
                case 3
                    NTotal = length(tPostStim);
                case 4
                    NTotal = length(tRespInterv);
            end
            clear startsBuffer stopsBuffer;
            
            % Waveform size specified for each of the primaries
            s = zeros(size(basisPrimary{1}, 2), NTotal);
            noiseStateVectorLMS = zeros(1, NTotal);
            noiseStateVectorLMinusM = zeros(1, NTotal);
            s(1, :) = 1;    % Background
            s(2, :) = 0;    % Modulation
            
            % Noise
            startIdx = 1:(1/(params.DurationSecsFrame)/(params.NoiseModulationFrequencyHz)):NTotal;
            endIdx = (1/(params.DurationSecsFrame))/(params.NoiseModulationFrequencyHz):(1/(params.DurationSecsFrame))/(params.NoiseModulationFrequencyHz):NTotal;
            DiscreteNoiseLevels = linspace(-1, 1, params.NoiseModulationDiscreteStates);
            
            for i = 1:length(startIdx)
                noiseStateVectorLMS(startIdx(i):endIdx(i)) = DiscreteNoiseLevels(randi(params.NoiseModulationDiscreteStates, 1));
                noiseStateVectorLMinusM(startIdx(i):endIdx(i)) =  DiscreteNoiseLevels(randi(params.NoiseModulationDiscreteStates, 1));
            end
            
            % Assign the noise vector
            s(3, :) = contrastLevels(C)*noiseStateVectorLMS;
            s(4, :) = contrastLevels(C)*noiseStateVectorLMinusM;
            
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
                    backgroundPreStimObj(v, C).IC = IC;
                    backgroundPreStimObj(v, C).startsBuffer = startsBuffer;
                    backgroundPreStimObj(v, C).stopsBuffer = stopsBuffer;
                case 2
                    backgroundISIStimObj(v, C).IC = IC;
                    backgroundISIStimObj(v, C).startsBuffer = startsBuffer;
                    backgroundISIStimObj(v, C).stopsBuffer = stopsBuffer;
                case 3
                    backgroundPostStimObj(v, C).IC = IC;
                    backgroundPostStimObj(v, C).startsBuffer = startsBuffer;
                    backgroundPostStimObj(v, C).stopsBuffer = stopsBuffer;
                case 4
                    backgroundRespIntervObj(v, C).IC = IC;
                    backgroundRespIntervObj(v, C).startsBuffer = startsBuffer;
                    backgroundRespIntervObj(v, C).stopsBuffer = stopsBuffer;
            end
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

counter = 1;
% Run interleaved staircases
for st1 = 1:NTrialsPerStaircase
    order = Shuffle(1:NInterleavedStaircases);
    for k = 1:NInterleavedStaircases
        % Get the contrast
        testContrast = maxContrast-getCurrentValue(st{order(k)})
        
        % Assemble the information needed for the trial
        % Find the index of the test contrast in our contrast
        % vector.
        [~, C] = min(abs(contrastLevels*maxContrast - testContrast));
        intval = theIntervals{k}(st1);
        
        timeStamp = datestr(now);
        clear sound;
        % Run the trials
        
        v = randi(params.NVersionsPerStimulusType);
        
        for m = 1:length(trialLogic)
            switch trialLogic(m)
                case 1
                    % Pre-stimulus background
                    startsBuffer = backgroundPreStimObj(v, C).startsBuffer;
                    stopsBuffer = backgroundPreStimObj(v, C).stopsBuffer;
                    IC = backgroundPreStimObj(v, C).IC;
                case 2
                    % Interval 1
                    T = 1;
                    if intval == 1
                        startsBuffer = eventObj(v, T, C).startsBuffer;
                        stopsBuffer = eventObj(v, T, C).stopsBuffer;
                        IC = eventObj(v, T, C).IC;
                    elseif intval == 2
                        startsBuffer = blankObj(v, C).startsBuffer;
                        stopsBuffer = blankObj(v, C).stopsBuffer;
                        IC = blankObj(v, C).IC;
                    end
                case 3
                    % Inter-stimulus background
                    startsBuffer = backgroundISIStimObj(v, C).startsBuffer;
                    stopsBuffer = backgroundISIStimObj(v, C).stopsBuffer;
                    IC = backgroundISIStimObj(v, C).IC;
                case 4
                    % Interval 2
                    T = 1;
                    if intval == 1
                        startsBuffer = blankObj(v, C).startsBuffer;
                        stopsBuffer = blankObj(v, C).stopsBuffer;
                        IC = blankObj(v, C).IC;
                    elseif intval == 2
                        startsBuffer = eventObj(v, T, C).startsBuffer;
                        stopsBuffer = eventObj(v, T, C).stopsBuffer;
                        IC = eventObj(v, T, C).IC;
                    end
                case 5
                    % Post-stimulus background
                    startsBuffer = backgroundPostStimObj(v, C).startsBuffer;
                    stopsBuffer = backgroundPostStimObj(v, C).stopsBuffer;
                    IC = backgroundPostStimObj(v, C).IC;
            end
            
            %% Play the sounds
            switch trialLogic(m)
                case 1
                    play(audStartTrial); % Play sound
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
        
        mileStone = mglGetSecs + params.DurationSecsFrame;
        i = 0;
        while i+1 <= length(backgroundRespIntervObj(v, C).IC)
            if mglGetSecs >= mileStone;
                i = i+1;
                mileStone = mglGetSecs + params.DurationSecsFrame;
                ol.setMirrors(backgroundRespIntervObj(v, C).startsBuffer(:, backgroundRespIntervObj(v, C).IC(i)), backgroundRespIntervObj(v, C).stopsBuffer(:, backgroundRespIntervObj(v, C).IC(i)));
            end
        end
        
        keyEvent = mglGetKeyEvent;
        if isempty(keyEvent)
            response(counter) = NaN;
            playblocking(buzzerplayer);
        else
            if (str2double(keyEvent.charCode) == 1) || (str2double(keyEvent.charCode) == 2)
                response(counter) = 1;
            elseif (str2double(keyEvent.charCode) == 6) || (str2double(keyEvent.charCode) == 5)
                response(counter) = 2;
            else
                response(counter) = NaN;
            end
        end
        if response(counter) == intval
            correctOrNot = 1;
        else
            correctOrNot = 0;
        end
        stop(audStartTrial); % Stop sound
        stop(audInterv1); % Stop sound
        stop(audInterv2); % Stop sound
        stop(audEndTrial); % Stop sound
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