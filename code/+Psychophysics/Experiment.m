function Experiment(ol,protocolParams)
% Experiment
%
% Description
%   Simple program to run a rating psychophysical task with OneLight
%   pulses.

% 7/7/16    ms      Wrote it.
% 11/17/2016 jr     Added additional perceptual dimensions and light
% 7/28/17   dhb     Pass OneLight object.

%% [DHB NOTE: MODULATIONS SHOULD BE TAKEN FROM PARAMETERS.]

%% [DHB NOTE: THERE WAS A NOTE HERE THAT A SWITCH STATEMENT ON protocolParams.protocolType WOULD BE GOOD.  I AGREE.]

%% [DHB NOTE: ADD 'verbose' key/value pair AND SUPRESS PRINTS TO COMMAND WINDOW WHEN IT IS FALSE]

%% Update Session Log file
protocolParams = OLSessionLog(protocolParams,mfilename,'StartEnd','start');

%% Parameters

% Speaking
SpeakRateDefault = getpref('protocolParams.approach', 'SpeakRateDefault');

% Adaptation time
protocolParams.adaptTimeSecs = 300;

% This needs to be checked against the modulations
protocolParams.frameDurationSecs = 1/64;

% Where the data goes
savePath = fullfile(getpref(protocolParams.approach, 'DataFilesBasePath'),protocolParams.observerID, protocolParams.todayDate, protocolParams.sessionName);
saveFileCSV = [protocolParams.observerID '-' protocolParams.protocolType '.csv'];
saveFileMAT = [protocolParams.observerID '-' protocolParams.protocolType '.mat'];
if ~exist(savePath)
    mkdir(savePath);
end

% Assemble the modulations
modulationDir = fullfile(getpref(protocolParams.approach, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);
pathToModFileLMS = ['ModulationStartsStops_MaxContrast3sSegment_MaxLMS' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];
pathToModFileMel = ['ModulationStartsStops_MaxContrast3sSegment_MaxMel' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];
pathToModFileLightFlux = ['Modulation-PulseMaxLightFlux_3s_MaxContrast3sSegment-' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];

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
protocolParams.NStimuli = length(stimOrder);
protocolParams.NPerceptualDimensions = length(perceptualDimensions);

% Wait for button press
Speak('Press key to start experiment', [], SpeakRateDefault);
WaitForKeyPress;
fprintf('* <strong>Experiment started</strong>\n');

% Open the file to save to
f = fopen(fullfile(savePath, saveFileCSV), 'w');

trialNum = 1;
for ii = 1:protocolParams.NStimuli
    is = stimOrder(ii);
    % Set to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 5 minutes
    Speak(sprintf('Adapt to background for %g minutes. Press key to start adaptation', protocolParams.adaptTimeSecs/60), [], SpeakRateDefault);
    WaitForKeyPress;
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(protocolParams.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    toc;
    
    for ps = 1:protocolParams.NPerceptualDimensions
        fprintf('\n* <strong>Trial %g</strong>\n', trialNum);
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Dimension: <strong>%s</strong>\n', perceptualDimensions{ps});
        fprintf('\t- Repeat: <strong>%g</strong>\n');
        Speak(['Wait for instructions.'], [], 200);
        WaitForKeyPress;
        
        keepGoing = true;
        counter = 1;
        while keepGoing
            fprintf('* <strong>Showing stimulus</strong>\n')
            OLFlicker(ol, stimStarts{is}', stimStops{is}', protocolParams.frameDurationSecs, 1);
            fprintf('Done.\n')
            counter =  counter+1;
            ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
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
save(fullfile(savePath, saveFileMAT), 'data', 'protocolParams');
fprintf('* Data saved.\n');
OLSessionLog(protocolParams,mfilename,'StartEnd','end');