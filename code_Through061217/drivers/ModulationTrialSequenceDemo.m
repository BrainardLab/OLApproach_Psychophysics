function params = ModulationTrialSequence(exp)
% params = MRITrialSequence(exp)

%% Setup basic parameters for the experiment
params = initParams(exp);

% Ask for the observer age
params.observerAgeInYears = GetWithDefault('Observer age', 32);

%% Put together the trial order
for i = 1:length(params.cacheFileName)
    % Construct the file name to load in age-specific file
    
    %modulationData{i} = LoadCalFile(params.cacheFileName{i}, [], [params.cacheDir '/modulations/']);
    [~, fileName, fileSuffix] = fileparts(params.cacheFileName{i});
    params.cacheFileName{i} = [fileName '-' num2str(params.observerAgeInYears) fileSuffix];
    try
        modulationData{i} = load(fullfile(params.cacheDir, 'modulations', params.cacheFileName{i}));
    catch
        error('ERROR: Cache file for observer with specific age could not be found');
    end
    
    % Check if we're using the most recent version of the cache file in the
    % modulation files. If not, prompt user to recompute.
    
    % Get the date of the cache used the modulation file
    tmpParams = modulationData{i}.modulation(1).params;
    
    % Load in the cache file so that we know what date the most recent cache is
    tmpParams.olCache = OLCache(tmpParams.cacheDir, tmpParams.oneLightCal);
    
    tmpCacheData = tmpParams.olCache.load(tmpParams.cacheFileName{1});
    
    % Compare the dates. If they don't match up, we have a more recent
    % cache file than we use in the modulation file. Tell experimenter to
    % re-generate the modulation files
    if ~strcmp(tmpCacheData.date, tmpParams.cacheDate{1})
        error('ERROR: Date of most recent cache file available and cache file used in modulation pre-cache are not consistent. Please regenerate modulation waveforms using OLFlickerComputeModulationWaveforms!')
    end
end

% Put together the trial order
block = struct();
for i = 1:params.nTrials
    fprintf('- Preconfiguring trial %i/%i...', i, params.nTrials);
    block(i).data = modulationData{params.theDirections(i)}.modulation(params.theDurationIndices(i), params.theFrequencyIndices(i), params.thePhaseIndices(i), params.theContrastScalingIndices(i));
    
    % Check if the 'attentionTask' flag is set. If it is, set up the task
    % (brief stimulus offset).
    block(i).attentionTask.flag = params.attentionTask(i);
    
    block(i).direction = block(i).data.direction;
    block(i).carrierFrequencyHz = block(i).data.params.carrierFrequency(params.theFrequencyIndices(i));
    
    if block(i).attentionTask.flag
        nSegments = block(i).data.params.trialDuration/params.attentionSegmentDuration;
        
        for s = 1:nSegments; % Iterate over the trials
            % Define the beginning and end of the 30 second esgments
            theStartSegmentIndex = 1/params.timeStep*params.attentionSegmentDuration*(s-1)+1;
            theStopSegmentIndex = 1/params.timeStep*params.attentionSegmentDuration*s;
            
            % Flip a coin to decide whether we'll have a blank event or not
            theCoinFlip = binornd(1, 0.5);
            
            % If yes, then define what the start and stop indices are for this
            if theCoinFlip
                theStartBlankIndex = randi([theStartSegmentIndex+params.attentionMarginDuration*1/params.timeStep theStopSegmentIndex-params.attentionMarginDuration*1/params.timeStep]);
                theStopBlankIndex = theStartBlankIndex+params.attentionBlankDuration*1/params.timeStep;
                
                % Blank out the settings
                block(i).data.correctedStops(:, theStartBlankIndex:theStopBlankIndex) = 250;
                
                % Assign a Boolean vector, allowing us to keep track of
                % when it blanked.
                block(i).attentionTask.T(theStartBlankIndex) = 1;
                block(i).attentionTask.T(theStopBlankIndex) = -1;
                
                block(i).attentionTask.segmentFlag(s) = 1;
                block(i).attentionTask.theStartBlankIndex(s) = theStartBlankIndex;
                block(i).attentionTask.theStopBlankIndex(s) = theStopBlankIndex;
            else
                % Assign a Boolean vector, allowing us to keep track of
                % when it blanked.
                block(i).attentionTask.T = 0;
                block(i).attentionTask.T = 0;
                
                block(i).attentionTask.segmentFlag(s) = 0;
                block(i).attentionTask.theStartBlankIndex(s) = -1;
                block(i).attentionTask.theStopBlankIndex(s) = -1;
            end
            
        end
    end
    fprintf('Done\n');
end

% Get rid of modulationData struct
clear modulationData;

%% Create the OneLight object.
% This makes sure we are talking to OneLight.
global ol
ol = OneLight;

fprintf('\n* Creating keyboard listener\n');
mglListener('init');

%% Run the trial loop.
params = trialLoop(params, block, exp);

% Toss the OLCache and OneLight objects because they are really only
% ephemeral.
params = rmfield(params, {'olCache'});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS FOR PROGRAM LOGIC %%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains:
%       - initParams(...)
%       - trialLoop(...)

function params = initParams(exp)
% params = initParams(exp)
% Initialize the parameters

% Load the config file for this condition.
cfgFile = ConfigFile(exp.configFileName);

% Convert all the ConfigFile parameters into simple struct values.
params = convertToStruct(cfgFile);
params.cacheDir = fullfile(exp.baseDir, 'cache');

% Load the calibration file.
cType = OLCalibrationTypes.(params.calibrationType);
params.oneLightCal = LoadCalFile(cType.CalFileName);

% Setup the cache.
params.olCache = OLCache(params.cacheDir, params.oneLightCal);

file_names = allwords(params.modulationFiles,',');
for i = 1:length(file_names)
    % Create the cache file name.
    [~, params.cacheFileName{i}] = fileparts(file_names{i});
end

end

function params = trialLoop(params, block, exp)
% [params, responseStruct] = trialLoop(params, cacheData, exp)
% This function runs the experiment loop
global ol

%% Store out the primaries from the cacheData into a cell.  The length of
% cacheData corresponds to the number of different stimuli that are being
% shown

% Set some other parameters
starts = zeros(1, ol.NumCols);

% Set the background to the 'idle' background appropriate for this
% trial.
fprintf('- Setting mirrors to background, waiting for t.\n');
ol.setMirrors(starts, block(1).data.correctedStopsBackground);

events = struct();

% Suppress keypresses going to the Matlab window.
ListenChar(2);

%% Code to wait for 't' -- the go-signal from the scanner
triggerReceived = false;
while ~triggerReceived
    key = mglGetKeyEvent;
    % If a key was pressed, get the key and exit.
    if ~isempty(key)
        keyPress = key.charCode;
        if (strcmp(keyPress,'t'))
            triggerReceived = true;
            fprintf('  * t received.\n');
            tBlockStart = mglGetSecs;
        end
    end
end

% Flush our keyboard queue.
mglGetKeyEvent;

% Stop receiving t
fprintf('- Starting trials.\n');

% Iterate over trials
for trial = 1:params.nTrials
    if params.waitForKeyPress
        ListenChar(0);
        pause;
    end
    fprintf('* Start trial %i/%i - %s, %i Hz.\n', trial, params.nTrials, block(trial).direction, block(trial).carrierFrequencyHz);
    % Launch into OLPDFlickerSettings.
    events(trial).tTrialStart = mglGetSecs;
    [events(trial).buffer, events(trial).t] = OLFlickerSettingsDemo(ol, block(trial).data.correctedStops, params.timeStep, 1, params.checkKB);
    events(trial).tTrialEnd = mglGetSecs;
    events(trial).attentionTask = block(trial).attentionTask;
end
tBlockEnd = mglGetSecs;

fprintf('- Done with block.\n');
ListenChar(0);

% Turn all mirrors off
ol.setAll(false);

% Put the event information in the struct
responseStruct.events = events;
responseStruct.tBlockStart = tBlockStart;
responseStruct.tBlockEnd = tBlockEnd;

fprintf('Total duration: %f s\n', responseStruct.tBlockEnd-responseStruct.tBlockStart);

% Tack data that we want for later analysis onto params structure.  It then
% gets passed back to the calling routine and saved in our standard place.
params.responseStruct = responseStruct;

end