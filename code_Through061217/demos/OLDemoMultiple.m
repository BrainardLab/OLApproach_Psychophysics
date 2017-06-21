% OLFlickerDemo.m

clear;
keepGoing = 1;
while keepGoing
    nMods = GetWithDefault('Cycle through how many modulations?', 1);
    for j = 1:nMods
        
        waveform{j} = [];
        %% Set some parameters
        waveform{j}.timeStep = 1/200;
        
        %% Gather some information.
        baseDir = fileparts(fileparts(which('OLDemo')));
        cacheDir = fullfile(baseDir, 'cache', 'stimuli');
        
        % Select cable information
        waveform{j}.cal = OLGetCalibrationStructure;
        
        % Setup the cache.
        olCache = OLCache(cacheDir, waveform{j}.cal);
        theDirections = {'MelanopsinDirectedCone', 'SDirected', 'LMPenumbraDirected', 'OmniSilent', 'SDirected', 'SConeHemoDirected', 'MelanopsinDirected', 'MelanopsinDirectedRobust', 'MelanopsinHemoRobust','MelanopsinConeHemoRobust', 'MelanopsinAllSilent', 'LConeHemoDirected', 'MConeHemoDirected', 'LMDirected', 'LMConeHemoDirected', 'LMinusMDirected', 'RodDirected', 'RodRobustHemo', 'Isochromatic', 'KleinSilent', 'MelanopsinLMHemoRobust', 'RodRobustLMHemo'};
        theAvailableCacheFiles = dir('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-*.mat');
        
        %% Get the waveform{j} direction
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
        [waveform{j}.cacheData,isStale] = olCache.load(['Cache-' availableCacheTypes{cacheIndex}]);
        assert(~isStale,'Cache file is stale, aborting.');
        
        %% Get the observerAge
        ageSelected = false;
        while ~ageSelected
            waveform{j}.theAge = GetWithDefault('Specify the observer age [20:60]', 32);
            if isscalar(waveform{j}.theAge) & waveform{j}.theAge >= 20 & waveform{j}.theAge <= 60;
                ageSelected = true;
            end
        end
        
        %% Get the waveform{j}
        thePossibleWaveforms = {'sin', 'cos', 'square', 'sawtooth'};
        waveformSelected = false;
        while ~waveformSelected
            waveform{j}.modulationWaveform = GetWithDefault('Specify the waveform [sin, cos, square, sawtooth]', 'sin');
            if any(strcmp(thePossibleWaveforms, waveform{j}.modulationWaveform))
                waveformSelected = true;
            end
        end
        
        %% Get the frequency
        frequencySelected = false;
        while ~frequencySelected
            waveform{j}.theFrequencyHz = GetWithDefault('Specify the frequency [Hz]', 1);
            if isscalar(waveform{j}.theFrequencyHz);
                frequencySelected = true;
            end
        end
        
        %% Get whether we want to amplitude modulate or not
        waveformModeSelected = false;
        thePossibleModulationModes = {'FM', 'AM'};
        while ~waveformModeSelected
            waveform{j}.modulationMode = GetWithDefault('Specifiy the waveform mode [AM, FM]', 'FM');
            if any(strcmp(thePossibleModulationModes, waveform{j}.modulationMode))
                waveformModeSelected = true;
            end
        end
        
        %% Ask for amplitude waveform{j} frequency if we're in AM
        if strcmp(waveform{j}.modulationMode, 'AM')
            frequencySelected = false;
            while ~frequencySelected
                waveform{j}.theEnvelopeFrequencyHz = GetWithDefault('Specify the envelope frequency [Hz]', 1);
                if isscalar(waveform{j}.theEnvelopeFrequencyHz);
                    frequencySelected = true;
                end
            end
        end
        
        %% Ask for contrast scaling
        contrastScalingSelected = false;
        while ~contrastScalingSelected
            waveform{j}.theContrastRelMax = GetWithDefault('Specify the contrast scaling [1 = max]', 1);
            if isscalar(waveform{j}.theContrastRelMax);
                contrastScalingSelected = true;
            end
        end
        
        %% Phase
        waveform{j}.thePhaseRad = 0;
        
        %% No cosine window for now
        waveform{j}.window.cosineWindowIn = false;
        waveform{j}.window.cosineWindowOut = false;
        waveform{j}.window.cosineDurationSecs = 1;
        waveform{j}.window.nWindowed = waveform{j}.window.cosineDurationSecs/waveform{j}.timeStep;
        
        runForSpecifiedTime = false;
        waveform{j}.durationSecs = 12;
        
        %% Construct the time vector
        if ~runForSpecifiedTime
            if strcmp(waveform{j}.modulationMode, 'AM')
                waveform{j}.t = 0:waveform{j}.timeStep:(1/waveform{j}.theEnvelopeFrequencyHz - waveform{j}.timeStep);
            else
                waveform{j}.t = 0:waveform{j}.timeStep:(1/waveform{j}.theFrequencyHz - waveform{j}.timeStep);
            end
        else
            waveform{j}.t = 0:waveform{j}.timeStep:waveform{j}.durationSecs-waveform{j}.timeStep;
        end
        
        % Calculate the waveform{j}
        waveform{j} = OLMakeWaveform(waveform{j}, waveform{j}.cal, waveform{j}.cacheData.data(waveform{j}.theAge).backgroundPrimary, waveform{j}.cacheData.data(waveform{j}.theAge).differencePrimary);
        
    end
    fprintf('*** Modulation ready');
    input('\n> Press enter to start, any key to stop waveform');
    modIndex = 1;
    keepModulating = 1;
    while keepModulating
        ol = OneLight;
        fprintf('> Modulating ...');
        OLFlickerStartsStopsDemo(ol, waveform{modIndex}.starts', waveform{modIndex}.stops', waveform{modIndex}.timeStep, Inf, true);
        fprintf('Done\n');
        modIndex = modIndex + 1;
        if mod(modIndex, nMods) == 0;
            modIndex = 1;
        end
        %keepGoing = GetWithDefault('Keep going?', 1);
    end
end