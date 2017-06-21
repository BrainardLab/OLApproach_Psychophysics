function OLMakeIsochromaticLocalizer(cal, flickerName, flickerContrast, observerAgeInYears)

% Setup the directories we'll use.  We count on the
% standard relative directory structure that we always
% use in our (BrainardLab) experiments.
baseDir = fileparts(fileparts(which('OLMakeInteractionModulation')));
configDir = fullfile(baseDir, 'config', 'modulations');
cacheDir = fullfile(baseDir, 'cache', 'stimuli');
modulationDir = fullfile(baseDir, 'cache', 'modulations');


%% Set up frequency parameters
freqLMCarrier = 10;
freqLMEnvelope = 0.5;
freqBG = 0.04;

%% Set up the waveform
waveform = [];
waveform.timeStep = 1/100;
waveform.durationSecs = 12.5;
waveform.cal = cal;

% No cosine window for now
waveform.window.cosineWindowIn = false;
waveform.window.cosineWindowOut = false;
waveform.window.cosineDurationSecs = 1;
waveform.window.nWindowed = waveform.window.cosineDurationSecs/waveform.timeStep;
waveform.window.type = 'cosine';
waveform.thePhaseRad = pi;
waveform.modulationWaveform = 'sin';

%% Setup the cache.
% Gather some information.
baseDir = fileparts(fileparts(which('OLDemo')));
cacheDir = fullfile(baseDir, 'cache', 'stimuli');
olCache = OLCache(cacheDir, waveform.cal);

%% Get L+M
% Load the cache data.
name1 = flickerName;
cacheData1 = olCache.load(['Cache-' name1]);

%% Specify the parameters
waveform1 = waveform;
waveform1.modulationMode = 'FM';
waveform1.theContrastRelMax = 1;
waveform1.theFrequencyHz = freqLMCarrier;
waveform1.thePhaseRad = 0;

% Construct the time vector
waveform1.t = 0:waveform1.timeStep:waveform1.durationSecs-waveform1.timeStep;

% Calculate the waveform
waveform1.theBackgroundPrimary = cacheData1.data(observerAgeInYears).backgroundPrimary;
waveform1.theDifferencePrimary = cacheData1.data(observerAgeInYears).differencePrimary;
waveform1 = OLMakeWaveform(waveform1, waveform1.cal, waveform1.theBackgroundPrimary, waveform1.theDifferencePrimary, 'primaries');

%% Specify the BG
waveformBG = waveform1;
waveformBG.modulationMode = 'FM';
waveformBG.theContrastRelMax = 0;
waveformBG.theFrequencyHz = 1;
waveformBG.thePhaseRad = 0;

% Construct the time vector
waveformBG.t = 0:waveformBG.timeStep:waveformBG.durationSecs-waveformBG.timeStep;
waveformBG.theBackgroundPrimary = cacheData1.data(observerAgeInYears).backgroundPrimary;
waveformBG.theDifferencePrimary = cacheData1.data(observerAgeInYears).differencePrimary;
waveformBG = OLMakeWaveform(waveformBG, waveformBG.cal, waveformBG.theBackgroundPrimary, waveformBG.theBackgroundPrimary, 'primaries');

% Construct the modulation
tic;

modulation = [waveformBG.primaries ; waveform1.primaries];
settings = OLPrimaryToSettings(waveform.cal, modulation');
[starts,stops] = OLSettingsToStartsStops(waveform.cal, settings);
toc;

%% Copy over these numbers
modulation.powerLevels = [waveformBG.powerLevels waveform1.powerLevels];
modulation.primaries = modulation;
modulation.starts = starts;
modulation.stops = stops;
modulation.settings = settings;
modulation.t = waveform1.t;
modulation.timeStep = waveform1.timeStep;
modulation.observerAgeInYears = observerAgeInYears;

%% Copy also metadata
% Construct the direction name
modulation.direction = [flickerName '_f' strrep(num2str(freqLMCarrier), '.', '') 'Hz'];
modulation.duration = waveform.durationSecs;      % Trial duration
modulation.cal = cal;
modulation.calID = OLGetCalID(cal);

% Save the frequencies and contrassts
modulation.freqLMCarrierHz = freqLMCarrier;

modulation.waveform1 = waveform1;
modulation.waveformBG = waveformBG;

% Put it all into a pseudo-object
modulationObj.modulation = modulation;
modulationObj.describe = '';

% Save out full version
preCacheFileFull = ['Modulation-Localizer-' num2str(waveform.durationSecs) 's' modulation.direction '-' num2str(observerAgeInYears) '-full.mat'];

fprintf(['* Saving full pre-calculated settings to ' preCacheFileFull '\n']);
save(fullfile(modulationDir, preCacheFileFull), 'modulationObj', '-v7.3');
fprintf('  - Done.\n');

% Save out reduced version
preCacheFile = ['Modulation-Localizer-' num2str(waveform.durationSecs) 's' modulation.direction '-' num2str(observerAgeInYears) '.mat'];
% Overwrite the modulation object
modulationObj.modulation = modulation;
modulationObj.describe = '';

fprintf(['* Saving reduced pre-calculated starts/stops to ' preCacheFile '\n']);
save(fullfile(modulationDir, preCacheFile), 'modulationObj', '-v7.3');
fprintf('  - Done.\n');
end
