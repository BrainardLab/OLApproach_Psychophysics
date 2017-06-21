function OLDemoSlowMel(theAge);

[~, cals] = LoadCalFile('OLBoxALongCableCEyePiece1');
cal = cals{end};

theDirections = {'MelanopsinDirectedLegacy', 'MelanopsinDirected', 'LMPenumbraDirected'};
nDirections = 1;%length(theDirections);

%% Gather some information.
baseDir = fileparts(fileparts(which('OLDemo')));
cacheDir = fullfile(baseDir, 'cache', 'stimuli');


for i = 1:nDirections
    
    % Setup the cache.
    olCache = OLCache(cacheDir, cal);
    
    % Load the cache data.
    [cacheData,isStale] = olCache.load(['Cache-' theDirections{i}]);
    assert(~isStale,'Cache file is stale, aborting.');
    waveform(i).timeStep = 0.2;
    waveform(i).modulationWaveform = 'sin';
    waveform(i).theFrequencyHz = 0.0333;
    waveform(i).modulationMode = 'FM';
    waveform(i).theContrastRelMax = 1;
    waveform(i).thePhaseRad = 0;
    waveform(i).window.cosineWindowIn = false;
    waveform(i).window.cosineWindowOut = false;
    waveform(i).window.cosineDurationSecs = 1;
    waveform(i).window.nWindowed = waveform(i).window.cosineDurationSecs/waveform(i).timeStep;
    waveform(i).window.type = 'cosine';
    runForSpecifiedTime = false;
    waveform(i).t = 0:waveform(i).timeStep:(1/waveform(i).theFrequencyHz - waveform(i).timeStep);
    
    
    theBackgroundPrimary = cacheData.data(theAge).backgroundPrimary;
    theDifferencePrimary = cacheData.data(theAge).differencePrimary;
    
    % Calculate the waveform(i)
    tmp = waveform(i);
    modulation{i} = OLMakeWaveform(tmp, cal, theBackgroundPrimary, theDifferencePrimary, 'full');
    
end

fprintf('*** Modulation ready');
input('\n> Press enter to start, any key to stop waveform');
ol = OneLight;
i = 1;

while true
    i = mod(i-1, nDirections)+1;
    fprintf('> Modulating - %s', theDirections{i});
    OLFlickerStartsStopsDemo(ol, modulation{i}.starts', modulation{i}.stops', modulation{i}.timeStep, Inf, true);
    fprintf('Done\n');
    i = i+1;
end

ls