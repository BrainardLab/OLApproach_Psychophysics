% OLFlickerDemo.m

clear;
keepGoing = 1;
while keepGoing
    
    waveform = [];
    %% Set some parameters
    waveform.timeStep = 1/100;
    
    %% Gather some information.
    baseDir = fileparts(fileparts(which('OLDemo')));
    cacheDir = fullfile(baseDir, 'cache', 'stimuli');
    
    % Select cable information
    waveform.cal = OLGetCalibrationStructure;
    
    % Setup the cache.
    olCache = OLCache(cacheDir, waveform.cal);
    theDirections = {'LMPenumbraDirected' 'MelanopsinDirectedLegacy' 'LMinusMDirected' 'LMSDirected' 'Isochromatic'};
    theAvailableCacheFiles = dir('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-*.mat');
    
    %% Get the waveform direction
    cacheFileSelected = false;
    % Figure out the available cache types.
    numAvailCacheTypes = 0;
    for i = 1:length(theDirections)
        fName = fullfile(cacheDir, ['Cache-' theDirections{i} '.mat']);
        if exist(fName, 'file')
            numAvailCacheTypes = numAvailCacheTypes + 1;
            availableCacheTypes(numAvailCacheTypes) = theDirections(i);
        end
    end
    
    % Now have the user select an available cache type to analyze.
    keepPrompting = true;
    while keepPrompting
        % Show the available cache types.
        fprintf('\n*** Available cache Types ***\n\n');
        for i = 1:length(availableCacheTypes)
            fprintf('%d - %s\n', i, availableCacheTypes{i});
        end
        fprintf('\n');
        
        cacheIndex = GetInput('Select a cache type', 'number', 1);
        
        % Check the selection.
        if cacheIndex >= 1 && cacheIndex <= numAvailCacheTypes
            keepPrompting = false;
        else
            fprintf('\n* Invalid selection\n');
        end
    end
    
    % Load the cache data.
    [waveform.cacheData,isStale] = olCache.load(['Cache-' availableCacheTypes{cacheIndex}]);
    assert(~isStale,'Cache file is stale, aborting.');
    
    %% Get the observerAge
    ageSelected = false;
    while ~ageSelected
        waveform.theAge = GetWithDefault('Specify the observer age [20:60]', 32);
        if isscalar(waveform.theAge) & waveform.theAge >= 20 & waveform.theAge <= 60;
            ageSelected = true;
        end
    end
    
    %% Get the waveform
    thePossibleWaveforms = {'sin', 'cos', 'square', 'sawtooth'};
    waveformSelected = false;
    while ~waveformSelected
        waveform.modulationWaveform = GetWithDefault('Specifiy the waveform [sin, cos, square, sawtooth]', 'sin');
        if any(strcmp(thePossibleWaveforms, waveform.modulationWaveform))
            waveformSelected = true;
        end
    end
    
    %% Get the frequency
    frequencySelected = false;
    while ~frequencySelected
        waveform.theFrequencyHz = GetWithDefault('Specify the frequency [Hz]', 1);
        if isscalar(waveform.theFrequencyHz);
            frequencySelected = true;
        end
    end
    
    %% Get whether we want to amplitude modulate or not
    waveformModeSelected = false;
    thePossibleModulationModes = {'FM', 'AM'};
    while ~waveformModeSelected
        waveform.modulationMode = GetWithDefault('Specifiy the waveform mode [AM, FM]', 'FM');
        if any(strcmp(thePossibleModulationModes, waveform.modulationMode))
            waveformModeSelected = true;
        end
    end
    
    %% Ask for amplitude waveform frequency if we're in AM
    if strcmp(waveform.modulationMode, 'AM')
        frequencySelected = false;
        while ~frequencySelected
            waveform.theEnvelopeFrequencyHz = GetWithDefault('Specify the envelope frequency [Hz]', 1);
            if isscalar(waveform.theEnvelopeFrequencyHz);
                frequencySelected = true;
            end
        end
    end
    
    %% Ask for contrast scaling
    contrastScalingSelected = false;
    while ~contrastScalingSelected
        waveform.theContrastRelMax = GetWithDefault('Specify the contrast scaling [1 = max]', 1);
        if isscalar(waveform.theContrastRelMax);
            contrastScalingSelected = true;
        end
    end
    
    %% Phase
    waveform.thePhaseRad = 0;
    
    %% No cosine window for now
    waveform.window.cosineWindowIn = false;
    waveform.window.cosineWindowOut = false;
    waveform.window.cosineDurationSecs = 1;
    waveform.window.nWindowed = waveform.window.cosineDurationSecs/waveform.timeStep;
    waveform.window.type = 'cosine';
    
    runForSpecifiedTime = false;
    waveform.durationSecs = 12;
    
    %% Construct the time vector
    if ~runForSpecifiedTime
        if strcmp(waveform.modulationMode, 'AM')
            waveform.t = 0:waveform.timeStep:(1/waveform.theEnvelopeFrequencyHz - waveform.timeStep);
        else
            waveform.t = 0:waveform.timeStep:(1/waveform.theFrequencyHz - waveform.timeStep);
        end
    else
        waveform.t = 0:waveform.timeStep:waveform.durationSecs-waveform.timeStep;
    end
    
    theBackgroundPrimary = waveform.cacheData.data(waveform.theAge).backgroundPrimary;
    theDifferencePrimary = waveform.cacheData.data(waveform.theAge).differencePrimary;
    
    % Calculate the waveform
    waveform = OLMakeWaveform(waveform, waveform.cal, theBackgroundPrimary, theDifferencePrimary);
    
    fprintf('*** Modulation ready');
    input('\n> Press enter to start, any key to stop waveform');
    ol = OneLight;
    while true
        input('\n> Press enter to start, any key to stop waveform');
        fprintf('> Modulating ...');
        OLFlickerStartsStopsDemo(ol, waveform.starts', waveform.stops', waveform.timeStep, Inf, true);
        fprintf('Done\n');
        keepGoing = GetWithDefault('Keep going?', 1);
    end
end