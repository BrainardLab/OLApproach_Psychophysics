% OLPurkinjeTreeDemo.m
clear;
observerName = input('Observer? ', 's');
waveform = [];
%% Set some parameters
waveform.timeStep = 1/256;

%% Gather some information.
baseDir = fileparts(fileparts(which('OLDemo')));
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

% Select cable information
waveform.cal = LoadCalFile(OLCalibrationTypes.('BoxBLongCableBEyePiece2').CalFileName);

% Setup the cache.
olCache = OLCache(cacheDir, waveform.cal);
theDirections = {'MelanopsinDirectedCone', 'SDirected', 'LMPenumbraDirected', 'OmniSilent', 'SDirected', 'SConeHemoDirected', 'MelanopsinDirected', 'MelanopsinDirectedRobust', 'MelanopsinHemoRobust','MelanopsinConeHemoRobust', 'MelanopsinAllSilent', 'LConeHemoDirected', 'MConeHemoDirected', 'LMDirected', 'LMConeHemoDirected', 'LMinusMDirected', 'RodDirected', 'RodRobustHemo', 'Isochromatic', 'KleinSilent', 'MelanopsinLMHemoRobust', 'RodRobustLMHemo'};
theAvailableCacheFiles = dir('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-*.mat');

% Load the cache data.
waveform.cacheData = olCache.load(['Cache-LMPenumbraDirected']);

%% Get the observerAge
ageSelected = false;
while ~ageSelected
    waveform.theAge = GetWithDefault('Specify the observer age [20:60]', 32);
    if isscalar(waveform.theAge) & waveform.theAge >= 20 & waveform.theAge <= 60;
        ageSelected = true;
    end
end

%% Get the waveform
waveform.modulationWaveform = 'sin';

%% Get the frequency
waveform.theFrequencyHz = 16;

%% Get whether we want to amplitude modulate or not
waveform.modulationMode = 'asym_duty';

%% Ask for frequency if we're in asym_duty
waveform.theEnvelopeFrequencyHz = 2/3;

%% Ask for contrast scaling
waveform.theContrastRelMax = 1;

%% Phase
waveform.thePhaseRad = 0;

%% No cosine window for now
waveform.window.cosineWindowIn = false;
waveform.window.cosineWindowOut = false;
waveform.window.cosineDurationSecs = 1;
waveform.window.nWindowed = waveform.window.cosineDurationSecs/waveform.timeStep;

runForSpecifiedTime = false;
waveform.durationSecs = 12;

%% Construct the time vector
waveform.t = 0:waveform.timeStep:(1/waveform.theEnvelopeFrequencyHz - waveform.timeStep);

%% Calculate the waveform
waveform = OLMakeWaveform(waveform, waveform.cal, waveform.cacheData.data(waveform.theAge).backgroundPrimary, waveform.cacheData.data(waveform.theAge).differencePrimary);

fprintf('*** Modulation ready');
keyboard;
input('\n> Press enter to start, any key to stop waveform');
modIndex = 1;
keepModulating = 1;
t0 = mglGetSecs;
    %ol = OneLight;
    fprintf('> Modulating ...');
    %OLFlickerStartsStopsDemo(ol, waveform{modIndex}.starts', waveform{modIndex}.stops', waveform{modIndex}.timeStep, Inf, true);
    fprintf('Done\n');

t1 = mglGetSecs;
timeSpent = t1-t0;

csvwrite([observerName '-OLPurkinjeTreeDemo.txt'], timeSpent)