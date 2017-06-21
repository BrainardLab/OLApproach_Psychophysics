function OLMakeInteractionModulation(cal, bgName, bgContrast, flickerContrast, observerAgeInYears)

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
waveform.durationSecs = 100;
waveform.cal = cal;

% No cosine window for now
waveform.window.cosineWindowIn = false;
waveform.window.cosineWindowOut = false;
waveform.window.cosineDurationSecs = 1;
waveform.window.nWindowed = waveform.window.cosineDurationSecs/waveform.timeStep;
waveform.window.type = 'cosine';
waveform.thePhaseRad = 0;
waveform.modulationWaveform = 'sin';

%% Setup the cache.
% Gather some information.
baseDir = fileparts(fileparts(which('OLDemo')));
cacheDir = fullfile(baseDir, 'cache', 'stimuli');
olCache = OLCache(cacheDir, waveform.cal);

%% Get L+M
% Load the cache data.
name1 = 'LMDirected';
cacheData1 = olCache.load(['Cache-' name1]);

% Specify the parameters
waveform1 = waveform;
waveform1.modulationMode = 'AM';
waveform1.theContrastRelMax = 1;
waveform1.theFrequencyHz = freqLMCarrier;
waveform1.theEnvelopeFrequencyHz = freqLMEnvelope;

% Construct the time vector
waveform1.t = 0:waveform1.timeStep:waveform1.durationSecs-waveform1.timeStep;

% Calculate the waveform
waveform1.theBackgroundPrimary = cacheData1.data(observerAgeInYears).backgroundPrimary;
waveform1.theDifferencePrimary = cacheData1.data(observerAgeInYears).differencePrimary;
waveform1 = OLMakeWaveform(waveform1, waveform1.cal, waveform1.theBackgroundPrimary, waveform1.theDifferencePrimary, 'primaries');

%% Get the data for the background
% Load the cache data.
name2 = bgName;

% Load in L+M if we don'[t have it
if strcmp(name2, 'LMDirectedScaled')
    name2 = 'LMDirected';
end
cacheData2 = olCache.load(['Cache-' name2]);

% Specify the parameters
waveform2 = waveform;
waveform2.modulationMode = 'FM';
waveform2.theContrastRelMax = 1;
waveform2.theFrequencyHz = freqBG;

% Construct the time vector
waveform2.t = 0:waveform2.timeStep:waveform2.durationSecs-waveform2.timeStep;

% Calculate the waveform
waveform2.theBackgroundPrimary = cacheData2.data(observerAgeInYears).backgroundPrimary;
waveform2.theDifferencePrimary = cacheData2.data(observerAgeInYears).differencePrimary;
waveform2 = OLMakeWaveform(waveform2, waveform2.cal, waveform2.theBackgroundPrimary, waveform2.theDifferencePrimary, 'primaries');

%% Construct the interaction
if isempty(bgContrast) || isempty(flickerContrast);
    figure;
    %% Explore the contrast space a little more systematic
    withinGamutMap = [];
    contrastScalars = 0:0.01:1;
    for i = 1:length(contrastScalars)
        for j = 1:length(contrastScalars)
            interaction = 0.5 + contrastScalars(i)*(waveform1.theDifferencePrimary) + contrastScalars(j)*(waveform2.theDifferencePrimary);
            withinGamutMap(i, j) = ~(any(any(interaction > 1)) || any(any(interaction < 0)));
            %plot(interaction'); input('');
        end
    end
    % Plot result
    maxContrast = 0.45;
    imagesc(maxContrast*contrastScalars, maxContrast*contrastScalars, withinGamutMap); c=colormap('gray');
    set(gca,'YDir','normal')
    xlabel([name2 ' contrast']);
    ylabel([name1 ' contrast']);
    pbaspect([1 1 1]);
    xlim([0 maxContrast]); ylim([0 maxContrast]);
    savefigghost([name1 '-' name2 '-interaction.png'], gcf, 'png')
else
    % Construct the interaction
    tic;
    interaction = 0.5 + flickerContrast*(waveform1.primaries-0.5) + bgContrast*(waveform2.primaries-0.5);
    settings = OLPrimaryToSettings(waveform.cal, interaction');
    [starts,stops] = OLSettingsToStartsStops(waveform.cal, settings);
    toc;
    
    % Background
    T_receptors = cacheData1.data(observerAgeInYears).describe.T_receptors;
    contrast = (T_receptors*(OLPrimaryToSpd(cal, waveform2.theBackgroundPrimary+waveform2.theDifferencePrimary)-OLPrimaryToSpd(cal, waveform2.theBackgroundPrimary)))./(T_receptors*OLPrimaryToSpd(cal, waveform2.theBackgroundPrimary));
    
    % Make the spds
    for i = 1:length(interaction)
        spd(:, i) = OLPrimaryToSpd(cal, interaction(i, :)');
    end
    
    cacheData1.data(observerAgeInYears).describe.T_receptors*spd
    
    for i = 1:4
        subplot(4, 1, i)
        ref = (cacheData1.data(observerAgeInYears).describe.T_receptors([i], :)*spd(:, 1))';
        plot((cacheData1.data(observerAgeInYears).describe.T_receptors([i], :)*spd)'/ref);
        ylim([0.5 1.5]);
        
    end
    
    %% Copy over these numbers
    modulation.powerLevels = flickerContrast*waveform1.powerLevels + bgContrast*waveform2.powerLevels;
    modulation.primaries = interaction;
    modulation.starts = starts;
    modulation.stops = stops;
    modulation.settings = settings;
    modulation.t = waveform1.t;
    modulation.timeStep = waveform1.timeStep;
    modulation.observerAgeInYears = observerAgeInYears;
    
    %% Copy also metadata
    % Construct the direction name
    if flickerContrast == 0
        modulation.direction = [bgName '_f' strrep(num2str(freqBG), '.', '') 'Hz_contrast' num2str(100*bgContrast, '%03.f')];
    else
        modulation.direction = [bgName '_f' strrep(num2str(freqBG), '.', '') 'Hz_contrast' num2str(100*bgContrast, '%03.f') '__LMFlicker_ef' strrep(num2str(freqLMEnvelope), '.', '') 'Hz_cf' strrep(num2str(freqLMCarrier), '.', '') 'Hz_contrast' num2str(100*flickerContrast, '%03.f')];
    end
    modulation.duration = waveform.durationSecs;      % Trial duration
    modulation.cal = cal;
    modulation.calID = OLGetCalID(cal);
    
    % Save the frequencies and contrassts
    modulation.freqLMCarrierHz = freqLMCarrier;
    modulation.freqLMEnvelopeHz = freqLMEnvelope;
    modulation.freqBGHz = freqBG;
    
    modulation.contrastLM = flickerContrast;
    modulation.contrastBG = bgContrast;
    
    modulation.waveform1 = waveform1;
    modulation.waveform2 = waveform2;
    
    % Put it all into a pseudo-object
    modulationObj.modulation = modulation;
    modulationObj.describe = '';
    
    % Save out full version
    preCacheFileFull = ['Modulation-Interaction-' num2str(waveform.durationSecs) 's' modulation.direction '-' num2str(observerAgeInYears) '-full.mat'];
    
    fprintf(['* Saving full pre-calculated settings to ' preCacheFileFull '\n']);
    save(fullfile(modulationDir, preCacheFileFull), 'modulationObj', '-v7.3');
    fprintf('  - Done.\n');
    
    % Save out reduced version
    preCacheFile = ['Modulation-Interaction-' num2str(waveform.durationSecs) 's' modulation.direction '-' num2str(observerAgeInYears) '.mat'];
    % Overwrite the modulation object
    modulationObj.modulation = modulation;
    modulationObj.describe = '';
    
    fprintf(['* Saving reduced pre-calculated starts/stops to ' preCacheFile '\n']);
    save(fullfile(modulationDir, preCacheFile), 'modulationObj', '-v7.3');
    fprintf('  - Done.\n');
    savefigghost(modulationDir, ['Modulation-Interaction-' num2str(waveform.durationSecs) 's' modulation.direction '-' num2str(observerAgeInYears) '.png'], gcf, 'png')
end
