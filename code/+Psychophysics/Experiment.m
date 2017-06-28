function Experiment
% Experiment
%
% Description
%   Simple program to run a rating psychophysical task with OneLight
%   pulses.

% 7/7/16    ms      Wrote it.
% 11/17/2016 jr     Added additional perceptual dimensions and light


% ALL OF THE PARAMETERS NEED TO COME OUT OF HERE.
% SHOULD THE ol OBJECT BE OPENED OR PASSED?  PASSED
% I WOULD THINK.

% SHOULD BE A switch on params.protocolType, so different protocols within
% Psychophysics approach can do different sorts of things.

% Flux to the stimulus labels.
SpeakRateDefault = getpref('OneLight', 'SpeakRateDefault');

% Parameters
params.simulate = true; % Option to run in simulate mode (true if not plugged into to a onelight box)
% Adaptation time
params.adaptTimeSecs = 300; % 5 minutes
params.frameDurationSecs = 1/64;
params.observerID = GetWithDefault('> <strong>Enter the observer name</strong>', 'MELA_xxxx');
observerID = params.observerID;
todayDate = datestr(now, 'mmddyy');
params.observerAgeInYrs = GetWithDefault('> <strong>Enter the observer age?</strong>', 20);
observerAgeInYrs = params.observerAgeInYrs;

protocol = 'MaxPulsePsychophysics';
dataPath = getpref('OneLight', 'dataPath');
savePath = fullfile(dataPath, protocol, params.observerID, datestr(now, 'mmddyy'), 'MatFiles');
saveFileCSV = [params.observerID '-' protocol '.csv'];
saveFileMAT = [params.observerID '-' protocol '.mat'];

if ~exist(savePath)
    mkdir(savePath);
end

% Assemble the modulations
modulationDir = fullfile(getpref('OneLight', 'modulationPath'));
pathToModFileLMS = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileMel = ['Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileLightFlux = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));
modFileLightFlux = load(fullfile(modulationDir, pathToModFileLightFlux));

startsLMS = modFileLMS.modulationObj.modulation.starts;
stopsLMS = modFileLMS.modulationObj.modulation.stops;
startsMel = modFileMel.modulationObj.modulation.starts;
stopsMel = modFileMel.modulationObj.modulation.stops;
startsLightFlux = modFileLightFlux.modulationObj.modulation.starts;
stopsLightFlux = modFileLightFlux.modulationObj.modulation.stops;

stimLabels = {'Light Flux' 'MaxLMS' 'MaxMel' 'Light Flux' 'MaxLMS' 'MaxMel' }; 
stimOrder = [1 3 2 1 3 2]; % Adjust stimulus presentation order here
stimStarts = {startsLightFlux startsLMS startsMel startsLightFlux startsLMS startsMel};
stimStops = {stopsLightFlux stopsLMS stopsMel stopsLightFlux stopsLMS stopsMel};
stimStartsBG = {modFileLightFlux.modulationObj.modulation.background.starts modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts modFileLightFlux.modulationObj.modulation.background.starts modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts};
stimStopsBG = {modFileLightFlux.modulationObj.modulation.background.stops modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops modFileLightFlux.modulationObj.modulation.background.stops modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops};

% Perceptual dimensions
perceptualDimensions = {'cool to warm', 'dull to glowing', 'colorless to colored', 'focused to blurred', 'slow to rapid', 'pleasant to unpleasant', 'dim to bright', 'smooth to jagged', 'constant to fading'};
% Experimental stage
params.NStimuli = length(stimOrder);
params.NPerceptualDimensions = length(perceptualDimensions);

% Wait for button press
Speak('Press key to start experiment', [], SpeakRateDefault);
WaitForKeyPress;
fprintf('* <strong>Experiment started</strong>\n');

% Open the OneLight
ol = OneLight('simulate',params.simulate);

% Open the file to save to
f = fopen(fullfile(savePath, saveFileCSV), 'w');

trialNum = 1;
for ii = 1:params.NStimuli
    is = stimOrder(ii);
    % Set to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 5 minutes
    Speak(sprintf('Adapt to background for %g minutes. Press key to start adaptation', params.adaptTimeSecs/60), [], SpeakRateDefault);
    WaitForKeyPress;
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(params.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    toc;
    
    for ps = 1:params.NPerceptualDimensions
        fprintf('\n* <strong>Trial %g</strong>\n', trialNum);
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Dimension: <strong>%s</strong>\n', perceptualDimensions{ps});
        %fprintf('\t- Repeat: <strong>%g</strong>\n', js);
        fprintf('\t- Repeat: <strong>%g</strong>\n');
        Speak(['Wait for instructions.'], [], 200);
        WaitForKeyPress;
        
        keepGoing = true;
        counter = 1;
        while keepGoing
            fprintf('* Showing stimulus...')
            modulationFlickerStartsStops(ol, stimStarts{is}, stimStops{is}, params.frameDurationSecs, 1);
            fprintf('Done.\n')
            counter =  counter+1;
            if counter == 2
                keepGoing = GetWithDefault('Show stimulus again? [0 = no, 1 = yes]', 0);
            else
                keepGoing = false;
            end
        end
        
        % Show the stimulus
        % Speak('Answer?', [], SpeakRateDefault);
        
        perceptualRating(trialNum) = GetInput('> Subject rating');
        fprintf('* <strong>Response</strong>: %g\n\n', perceptualRating(trialNum))
        
        % Save the data
        %fprintf(f, '%g,%s,%s,%g,%.3f\n', trialNum, stimLabels{is}, perceptualDimensions{ps}, js, perceptualRating(trialNum));
        fprintf(f, '%g,%s,%s,%g,%.3f\n', trialNum, stimLabels{is}, perceptualDimensions{ps}, perceptualRating(trialNum));
        
        % Save the for this trial
        data(trialNum).trialNum = trialNum;
        data(trialNum).stimLabel = stimLabels{is};
        data(trialNum).perceptualDimension = perceptualDimensions{ps};
        data(trialNum).response = perceptualRating(trialNum);
        
        trialNum = trialNum + 1;
    end
end

% Save the data as in the end
save(fullfile(savePath, saveFileMAT), 'data', 'params');
fprintf('* Data saved.\n');