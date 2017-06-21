function OLDemoFastMel(theAge);

theAge = 32;
cal = OLGetCalibrationStructure;


theDirections = {'LMDirected', 'LMinusMDirected' 'LMDirected', 'LMinusMDirected'};
nDirections = length(theDirections);

%% Gather some information.
baseDir = fileparts(fileparts(which('OLDemo')));
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

nModulations = 4;
theFreqs = [16 16 32 32];

for i = 1:nModulations
    
    % Setup the cache.
    olCache = OLCache(cacheDir, cal);
    
    % Load the cache data.
    [cacheData,isStale] = olCache.load(['Cache-' theDirections{i}]);
    assert(~isStale,'Cache file is stale, aborting.');
    waveform(i).timeStep = 1/200;
    waveform(i).modulationWaveform = 'sin';
    waveform(i).theFrequencyHz = theFreqs(i);
    waveform(i).modulationMode = 'FM';
    waveform(i).theContrastRelMax = 1;
    waveform(i).thePhaseRad = 0;
    waveform(i).window.cosineWindowIn = false;
    waveform(i).window.cosineWindowOut = false;
    waveform(i).window.cosineDurationSecs = 1;
    waveform(i).theEnvelopeFrequencyHz = 1;
    waveform(i).window.nWindowed = waveform(i).window.cosineDurationSecs/waveform(i).timeStep;
    waveform(i).window.type = 'cosine';
    runForSpecifiedTime = false;
    %% Construct the time vector
    if ~runForSpecifiedTime
        if strcmp(waveform(i).modulationMode, 'AM')
            waveform(i).t = 0:waveform(i).timeStep:(1/waveform(i).theEnvelopeFrequencyHz - waveform(i).timeStep);
        else
            waveform(i).t = 0:waveform(i).timeStep:(1/waveform(i).theFrequencyHz - waveform(i).timeStep);
        end
    else
        waveform(i).t = 0:waveform(i).timeStep:waveform(i).durationSecs-waveform(i).timeStep;
    end
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
    %i = mod(i-1, nDirections)+1;
    fprintf('> Modulating - %s at %g Hz', theDirections{i}, theFreqs(i));
    [~, ~, key] = OLFlickerStartsStopsDemo(ol, modulation{i}.starts', modulation{i}.stops', modulation{i}.timeStep, Inf, true);
    fprintf('Done\n');
    %i = i+1;
    
    if str2num(key.charCode) == 6;
        i = 1;
    end
    
    if str2num(key.charCode) == 1;
        i = 2;
    end
    
    
    if str2num(key.charCode) == 5;
        i = 3;
    end
    
    if str2num(key.charCode) == 2;
        i = 4;
        
    end
end