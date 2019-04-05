function Experiment(ol,protocolParams,varargin)
%%Experiment  MaxMelPulsePsychophysics protocol experiment driver
%
% Description:
%     Simple program to run a rating psychophysical task with OneLight pulses.
%
% Input:
%    ol (object)              An open OneLight object.
%    protocolParams (struct)  The protocol parameters structure.
%
% Output:
%    None.
%
% Optional key/value pairs:
%    verbose (logical)         true       Be chatty?

% 7/7/16    ms      Wrote it.
% 11/17/16  jr      Added additional perceptual dimensions and light
% 7/28/17   dhb     Pass OneLight object.

%% Parse
p = inputParser;
p.addParameter('verbose',true,@islogical);
p.parse;

%% Update Session Log file
protocolParams = OLSessionLog(protocolParams,mfilename,'StartEnd','start');

%% Speaking rate
speakRateDefault = getpref(protocolParams.approach, 'SpeakRateDefault');

%% Where the data goes
savePath = fullfile(getpref(protocolParams.protocol, 'DataFilesBasePath'),protocolParams.observerID, protocolParams.todayDate, protocolParams.sessionName);
if ~exist(savePath,'dir')
    mkdir(savePath);
end
saveFileCSV = [protocolParams.observerID '-' protocolParams.protocolType '.csv'];
saveFileMAT = [protocolParams.observerID '-' protocolParams.protocolType '.mat'];

%% Set stimulus labels and presentation order.
stimLabels = {'Light Flux' 'MaxLMS' 'MaxMel'}; 
stimOrder = [1 3 2 1 3 2]; 

%% Get the modulation starts/stops
%
% Get path and filenames.  Check that someone has not
% done something unexpected in the calling program.
modulationDir = fullfile(getpref(protocolParams.protocol, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);
for mm = 1:length(protocolParams.modulationNames)
    fullModulationNames{mm} = sprintf('ModulationStartsStops_%s_%s_trialType_%d', protocolParams.modulationNames{mm}, protocolParams.directionNames{mm}, mm);
end
if (~strcmp(protocolParams.directionNames{1}(1:6),'MaxMel'))
    error('Direction order not as expected');
end
if (~strcmp(protocolParams.directionNames{2}(1:6),'MaxLMS'))
    error('Direction order not as expected');
end
if (~strcmp(protocolParams.directionNames{3}(1:9),'LightFlux'))
    error('Direction order not as expected');
end
pathToModFileMel = [fullModulationNames{1} '.mat'];
pathToModFileLMS = [fullModulationNames{2} '.mat'];
pathToModFileLightFlux = [fullModulationNames{3} '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));
modFileLightFlux = load(fullfile(modulationDir, pathToModFileLightFlux));

% Extract the starts and stops that we need
startsLMS = modFileLMS.modulationData.modulation.starts;
stopsLMS = modFileLMS.modulationData.modulation.stops;
startsMel = modFileMel.modulationData.modulation.starts;
stopsMel = modFileMel.modulationData.modulation.stops;
startsLightFlux = modFileLightFlux.modulationData.modulation.starts;
stopsLightFlux = modFileLightFlux.modulationData.modulation.stops;

% Put starts stops into cell arrays that can be indexed by stimOrder variable above
stimStarts = {startsLightFlux startsLMS startsMel};
stimStops = {stopsLightFlux stopsLMS stopsMel};
stimFrameDurations = [modFileLightFlux.modulationData.waveformParams.timeStep modFileLMS.modulationData.waveformParams.timeStep modFileMel.modulationData.waveformParams.timeStep];
stimStartsBG = {modFileLightFlux.modulationData.modulation.background.starts modFileLMS.modulationData.modulation.background.starts modFileMel.modulationData.modulation.background.starts};
stimStopsBG = {modFileLightFlux.modulationData.modulation.background.stops modFileLMS.modulationData.modulation.background.stops modFileMel.modulationData.modulation.background.stops};

%% Perceptual dimensions
perceptualDimensions = {'cool to warm', 'dull to glowing', 'colorless to colored', 'focused to blurred', 'slow to rapid', 'pleasant to unpleasant', 'dim to bright', 'smooth to jagged', 'constant to fading'};
protocolParams.NStimuli = length(stimOrder);
protocolParams.NPerceptualDimensions = length(perceptualDimensions);

%% Wait for button press
Speak('Press key to start experiment', [], speakRateDefault);
if (~protocolParams.simulate.oneLight), WaitForKeyPress; end
fprintf('* <strong>Experiment started</strong>\n');

%% Open the text file to save to on a trial by trial basis
f = fopen(fullfile(savePath, saveFileCSV), 'w');

%% Run the trials
trialNum = 1;
for ii = 1:protocolParams.NStimuli
    % Get stimulus index
    is = stimOrder(ii);
    
    % Set OL to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 5 minutes
    Speak(sprintf('Adapt to background for %g minutes. Press key to start adaptation', protocolParams.experimentAdaptTimeSecs/60), [], speakRateDefault);
    if (~protocolParams.simulate.oneLight), WaitForKeyPress; end
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], speakRateDefault);
    mglWaitSecs(protocolParams.experimentAdaptTimeSecs);
    Speak('Adaptation complete', [], speakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    
    % Loop over perceptual dimensions
    for ps = 1:protocolParams.NPerceptualDimensions
        fprintf('\n* <strong>Trial %g</strong>\n', trialNum);
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Dimension: <strong>%s</strong>\n', perceptualDimensions{ps});
        fprintf('\t- Repeat?');
        Speak(['Wait for instructions.'], [], 200);
        if (~protocolParams.simulate.oneLight), WaitForKeyPress; end
        
        keepGoing = true;
        counter = 1;
        while keepGoing
            fprintf('* <strong>Showing stimulus</strong>\n')
            OLFlicker(ol, stimStarts{is}, stimStops{is}, stimFrameDurations(is), 1);
            fprintf('Done.\n')
            counter =  counter+1;
            ol.setMirrors(stimStartsBG{is}, stimStopsBG{is});
            if counter == 2
                if (~protocolParams.simulate.oneLight), keepGoing = GetWithDefault('Show stimulus again? [0 = no, 1 = yes]', 0); end
            else
                keepGoing = false;
            end    
        end
        
        % Show the stimulus
        Speak('Answer?', [], speakRateDefault);
        if (~protocolParams.simulate.oneLight) 
            perceptualRating(trialNum) = GetInput('> Subject rating');
        else
            perceptualRating(trialNum) = 1;
        end
        fprintf('* <strong>Response</strong>: %g\n\n', perceptualRating(trialNum))
        
        % Write the data for this trial.
        fprintf(f, '%g,%s,%s,%g,%.3f\n', trialNum, stimLabels{is}, perceptualDimensions{ps}, perceptualRating(trialNum));
        
        % Save the for this trial
        data(trialNum).trialNum = trialNum;
        data(trialNum).stimLabel = stimLabels{is};
        data(trialNum).perceptualDimension = perceptualDimensions{ps};
        data(trialNum).response = perceptualRating(trialNum);
        
        trialNum = trialNum + 1;
    end
end

%% Close the text file
fclose(f);

%% Save the data as a mat file in the end
save(fullfile(savePath, saveFileMAT), 'data', 'protocolParams');
fprintf('* Data saved.\n');

%% Do session logging
OLSessionLog(protocolParams,mfilename,'StartEnd','end');