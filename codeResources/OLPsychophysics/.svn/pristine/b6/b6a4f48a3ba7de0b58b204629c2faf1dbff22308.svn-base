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
cacheNoise = allwords(params.NoiseModulationTypes);
cacheNoise1 = olCache.load(['Cache-' cacheNoise{1}]);
cacheNoise2 = olCache.load(['Cache-' cacheNoise{2}]);
noisePrimary1 = params.NoiseModulationContrast(1)*(cacheNoise1.data(exp.observerAge).modulationPrimarySignedPositive-cacheNoise1.data(exp.observerAge).backgroundPrimary);
noisePrimary2 = params.NoiseModulationContrast(2)*(cacheNoise2.data(exp.observerAge).modulationPrimarySignedPositive-cacheNoise2.data(exp.observerAge).backgroundPrimary);

params.caches.cacheNoise1 = cacheNoise1;
params.caches.cacheNoise2 = cacheNoise2;

for m = 1:params.NTrialTypes
    cacheModulation1 = olCache.load(['Cache-' cacheModulation{m}]);
    bgPrimary = cacheModulation1.data(exp.observerAge).backgroundPrimary;
    diffPrimary = cacheModulation1.data(exp.observerAge).modulationPrimarySignedPositive-cacheModulation1.data(exp.observerAge).backgroundPrimary;
    nullingCache1 = olCache.load(['Cache-LMSDirectedNulling']); % Contains 10% contrast
    nullingCache1Diff = nullingCache1.data(exp.observerAge).modulationPrimarySignedPositive-nullingCache1.data(exp.observerAge).backgroundPrimary;
    nullingCache2 = olCache.load(['Cache-LMinusMDirectedNulling']); % Contains 10% contrast
    nullingCache2Diff = nullingCache2.data(exp.observerAge).modulationPrimarySignedPositive-nullingCache2.data(exp.observerAge).backgroundPrimary;
    switch cacheModulation{m}
        % The nulling values are from MelLMS_GrandMean.csv
        % The value 0.7241 comes from 0.42/0.58. The cache contains the
        % contrast at 58%, but we nulled at 42%.
        case 'MelanopsinDirectedPenumbralIgnore'
            nullingCache1Weight = -0.009391/0.1;
            nullingCache2Weight = -0.013146/0.1;
            diffPrimary = 0.7241*diffPrimary + nullingCache1Weight*nullingCache1Diff + nullingCache2Weight*nullingCache2Diff;
        case 'LMSDirected'
            nullingCache1Weight = 0;
            nullingCache2Weight = 0.014859/0.1;
            diffPrimary = 0.7241*diffPrimary + nullingCache1Weight*nullingCache1Diff + nullingCache2Weight*nullingCache2Diff;
        case 'LightFlux'
            diffPrimary = 0.7241*diffPrimary;
    end
    
    basisPrimary{m} = [bgPrimary diffPrimary noisePrimary1 noisePrimary2];
    params.basisPrimary{m} = basisPrimary{m};
    params.caches.cacheModulation{m} = cacheModulation1;
end

%% Set up sounds
Fs = 8192;
nSeconds = params.DurationSecsInterval; % Leave a little margin
frequencyInterv1 = 440; frequencyInterv2 = 330;
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

saveStimuliFile = fullfile(exp.subjectDataDir, 'stimuli', [params.obsIDAndRun '.mat']);
%% Event objects
fprintf('*** Calculating events...');
for T = 1:params.NTrialTypes
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
        s(3, :) = noiseStateVectorLMS;
        %s(3, cosineWindowInIdx) = 2*s(3, cosineWindowInIdx);
        %s(3, cosineWindowOutIdx) = 2*s(3, cosineWindowOutIdx);
        s(4, :) = noiseStateVectorLMinusM;
        %s(4, cosineWindowInIdx) = 2*s(4, cosineWindowInIdx);
        %s(4, cosineWindowOutIdx) = 2*s(4, cosineWindowOutIdx);
        
        % Calculate the primary settings as a simple linear operation
        primariesBuffer = basisPrimary{T}*s;
        
        % Find the unique primary settings up to a tolerance value
        %[uniqPrimariesBuffer, ~, IC] = uniquetol(primariesBuffer', 'ByRows', true);
        [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
        uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
        
        % Convert the unique primaries to starts and stops
        settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
        for si = 1:size(settingsBuffer, 2)
            [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
        end
        
        eventObj(v, T).IC = IC;
        eventObj(v, T).startsBuffer = startsBuffer;
        eventObj(v, T).stopsBuffer = stopsBuffer;
        eventObj(v, T).settingsBuffer = settingsBuffer;
        eventObj(v, T).primariesBuffer = primariesBuffer;
        for ii = 1:size(primariesBuffer, 2)
            eventObj(v, T).spd(:, ii) = OLPrimaryToSpd(cal, primariesBuffer(:, ii));
        end
    end
end
fprintf('done.\n');

%% Blank event object
fprintf('*** Calculating blanks...');
for v = 1:params.NVersionsPerStimulusType
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
    s(3, :) = noiseStateVectorLMS;
    %s(3, cosineWindowInIdx) = 2*s(3, cosineWindowInIdx);
    %s(3, cosineWindowOutIdx) = 2*s(3, cosineWindowOutIdx);
    s(4, :) = noiseStateVectorLMinusM;
    %s(4, cosineWindowInIdx) = 2*s(4, cosineWindowInIdx);
    %s(4, cosineWindowOutIdx) = 2*s(4, cosineWindowOutIdx);
    
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
    
    blankObj(v).IC = IC;
    blankObj(v).startsBuffer = startsBuffer;
    blankObj(v).stopsBuffer = stopsBuffer;
    blankObj(v).settingsBuffer = settingsBuffer;
    blankObj(v).primariesBuffer = primariesBuffer;
    for ii = 1:size(primariesBuffer, 2)
        blankObj(v).spd(:, ii) = OLPrimaryToSpd(cal, primariesBuffer(:, ii));
    end
end
fprintf('done.\n');

%% Background calculations
fprintf('*** Calculating background...');
for T = [1:4]
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
        s(3, :) = noiseStateVectorLMS;
        s(4, :) = noiseStateVectorLMinusM;
        
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
                backgroundPreStimObj(v).IC = IC;
                backgroundPreStimObj(v).startsBuffer = startsBuffer;
                backgroundPreStimObj(v).stopsBuffer = stopsBuffer;
                backgroundPreStimObj(v).settingsBuffer = settingsBuffer;
                backgroundPreStimObj(v).primariesBuffer = primariesBuffer;
                for ii = 1:size(primariesBuffer, 2)
                    backgroundPreStimObj(v).spd(:, ii) = OLPrimaryToSpd(cal, primariesBuffer(:, ii));
                end
            case 2
                backgroundISIStimObj(v).IC = IC;
                backgroundISIStimObj(v).startsBuffer = startsBuffer;
                backgroundISIStimObj(v).stopsBuffer = stopsBuffer;
                backgroundISIStimObj(v).settingsBuffer = settingsBuffer;
                backgroundISIStimObj(v).primariesBuffer = primariesBuffer;
                for ii = 1:size(primariesBuffer, 2)
                    backgroundISIStimObj(v).spd(:, ii) = OLPrimaryToSpd(cal, primariesBuffer(:, ii));
                end
            case 3
                backgroundPostStimObj(v).IC = IC;
                backgroundPostStimObj(v).startsBuffer = startsBuffer;
                backgroundPostStimObj(v).stopsBuffer = stopsBuffer;
                backgroundPostStimObj(v).settingsBuffer = settingsBuffer;
                backgroundPostStimObj(v).primariesBuffer = primariesBuffer;
                for ii = 1:size(primariesBuffer, 2)
                    backgroundPostStimObj(v).spd(:, ii) = OLPrimaryToSpd(cal, primariesBuffer(:, ii));
                end
            case 4
                backgroundRespIntervObj(v).IC = IC;
                backgroundRespIntervObj(v).startsBuffer = startsBuffer;
                backgroundRespIntervObj(v).stopsBuffer = stopsBuffer;
                backgroundRespIntervObj(v).settingsBuffer = settingsBuffer;
                backgroundRespIntervObj(v).primariesBuffer = primariesBuffer;
                for ii = 1:size(primariesBuffer, 2)
                    backgroundRespIntervObj(v).spd(:, ii) = OLPrimaryToSpd(cal, primariesBuffer(:, ii));
                end
        end
    end
end
fprintf('done.\n');

mkdir(fullfile(exp.subjectDataDir, 'stimuli'));
params.stimulus.eventObj = eventObj;
params.stimulus.blankObj = blankObj;
params.stimulus.backgroundPreStimObj = backgroundPreStimObj;
params.stimulus.backgroundISIStimObj = backgroundISIStimObj;
params.stimulus.backgroundPostStimObj = backgroundPostStimObj;
params.stimulus.backgroundRespIntervObj = backgroundRespIntervObj;
save(saveStimuliFile, 'exp', 'params');

%% The trial vector
trialLogic = 1:5;
StimFirstOrSecondOrdered = [ones(1, params.NTrialsPerBlock/2) 2*ones(1, params.NTrialsPerBlock/2)];

ol = OneLight;
% Make sure that no key presses come to the MATLAB console
mglListener(7, ['1' '6' 'z']);
if params.DoDarkAdaptation
    OLAllMirrorsOff; OLDarkTimer;
end

settings = OLPrimaryToSettings(cal, bgPrimary);
[starts, stops] = OLSettingsToStartsStops(cal, settings);
ol.setMirrors(starts, stops);

if params.DoBackgroundAdaptation
    system('say -r 230 Press any key to start.');
    pause;
    system('say -r 210 Adapt to background for five minutes');
    mglWaitSecs(60);
    system('say -r 210 4 minutes left.');
    mglWaitSecs(60);
    system('say -r 210 3 minutes left.');
    mglWaitSecs(60);
    system('say -r 210 2 minutes left.');
    mglWaitSecs(60);
    system('say -r 210 1 minute left.');
    mglWaitSecs(60);
    system('say -r 210 Adaptation complete. The experiment begins now.');
end

fid = fopen(fullfile(exp.subjectDataDir, [params.obsIDAndRun '.csv']), 'w');
for block = 1:params.NBlocks
    system(['say -r 210 Block ' num2str(block) ' of ' num2str(params.NBlocks) '. Press any key to start.']);
    pause;
    
    StimFirstOrSecond = Shuffle(StimFirstOrSecondOrdered);
    
    for k = 1:params.NTrialsPerBlock
        system('say -r 210 Press key.'); pause;
        currTrialGlobal = params.NTrialsPerBlock*(block-1)+k;
        v = randi(params.NVersionsPerStimulusType);
        timeStamp = datestr(now);
        clear sound;
        % Run the trials
        for m = 1:length(trialLogic)
            switch trialLogic(m)
                case 1
                    % Pre-stimulus background
                    startsBuffer = backgroundPreStimObj(v).startsBuffer;
                    stopsBuffer = backgroundPreStimObj(v).stopsBuffer;
                    IC = backgroundPreStimObj(v).IC;
                case 2
                    % Interval 1
                    T = params.BlockOrder(block);
                    if StimFirstOrSecond(k) == 1
                        startsBuffer = eventObj(v, T).startsBuffer;
                        stopsBuffer = eventObj(v, T).stopsBuffer;
                        IC = eventObj(v, T).IC;
                    elseif StimFirstOrSecond(k) == 2
                        startsBuffer = blankObj(v).startsBuffer;
                        stopsBuffer = blankObj(v).stopsBuffer;
                        IC = blankObj(v).IC;
                    end
                case 3
                    % Inter-stimulus background
                    startsBuffer = backgroundISIStimObj(v).startsBuffer;
                    stopsBuffer = backgroundISIStimObj(v).stopsBuffer;
                    IC = backgroundISIStimObj(v).IC;
                case 4
                    % Interval 2
                    T = params.BlockOrder(block);
                    if StimFirstOrSecond(k) == 1
                        startsBuffer = blankObj(v).startsBuffer;
                        stopsBuffer = blankObj(v).stopsBuffer;
                        IC = blankObj(v).IC;
                    elseif StimFirstOrSecond(k) == 2
                        startsBuffer = eventObj(v, T).startsBuffer;
                        stopsBuffer = eventObj(v, T).stopsBuffer;
                        IC = eventObj(v, T).IC;
                    end
                case 5
                    % Post-stimulus background
                    startsBuffer = backgroundPostStimObj(v).startsBuffer;
                    stopsBuffer = backgroundPostStimObj(v).stopsBuffer;
                    IC = backgroundPostStimObj(v).IC;
            end
            
            %% Play the sounds
            switch trialLogic(m)
                case 2
                    play(audInterv1); % Play sound
                case 4
                    play(audInterv2); % Play sound
            end
            
            %% Show the stimulus
            %tic
            mileStone = mglGetSecs + params.DurationSecsFrame;
            i = 0;
            %tic
            while i+1 <= length(IC)
                if mglGetSecs >= mileStone;
                    i = i+1;
                    mileStone = mglGetSecs + params.DurationSecsFrame;
                    ol.setMirrors(startsBuffer(:, IC(i)), stopsBuffer(:, IC(i)));
                end
            end
            %toc
            
        end
        play(audStartTrial);
        mglGetKeyEvent;
        
        
        mileStone = mglGetSecs + params.DurationSecsFrame;
        i = 0;
        while i+1 <= length(backgroundRespIntervObj(v).IC)
            if mglGetSecs >= mileStone;
                i = i+1;
                mileStone = mglGetSecs + params.DurationSecsFrame;
                ol.setMirrors(backgroundRespIntervObj(v).startsBuffer(:, backgroundRespIntervObj(v).IC(i)), backgroundRespIntervObj(v).stopsBuffer(:, backgroundRespIntervObj(v).IC(i)));
            end
        end
        
        keyEvent = mglGetKeyEvent;
        if isempty(keyEvent)
            response(k) = NaN;
            %playblocking(buzzerplayer);
        else
            if (str2double(keyEvent.charCode) == 1) || (str2double(keyEvent.charCode) == 2)
                response(k) = 1;
            elseif (str2double(keyEvent.charCode) == 6) || (str2double(keyEvent.charCode) == 5)
                response(k) = 2;
            else
                response(k) = NaN;
            end
        end
        
        correctOrNo = (response(k) == StimFirstOrSecond(k));
        stop(audInterv1); % Stop sound
        stop(audInterv2); % Stop sound
        stop(audStartTrial);
        fprintf(fid, '%s,%s,%s,%g,%g,%g,%g,%g,%g\n', timeStamp, params.obsID, cacheModulation{params.BlockOrder(block)}, block, k, currTrialGlobal, StimFirstOrSecond(k), response(k), correctOrNo);
    end
end
fclose(fid);


system('say Experiment finished.');

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