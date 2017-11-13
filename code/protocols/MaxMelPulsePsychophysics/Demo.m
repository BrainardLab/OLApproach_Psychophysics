function Demo(ol,protocolParams,varargin)
%%Demo  Simple program for demo of MaxMel/MaxLMS pulses 
%
% Description:
%    Simple program for demo of MaxMel/MaxLMS pulses
%
% Optional key/value pairs:
%    verbose (logical)         true       Be chatty?

% 7/7/16    ms      Wrote it.
% 7/28/17   dhb     Pass ol object

%% Parse
p = inputParser;
p.addParameter('verbose',true,@islogical);
p.parse;

%% Update Session Log file
protocolParams = OLSessionLog(protocolParams,mfilename,'StartEnd','start');

%% Speaking rate
speakRateDefault = getpref(protocolParams.approach, 'SpeakRateDefault');

%% Parameters for demo
nRepeatsPerStimulus = 3;
nStimuli = 2;

%% Set stimulus labels
stimLabels = {'MaxLMS' 'MaxMel'}; 

%% Get the modulation starts/stops
%
% Get path and filenames.  Check that someone has not
% done something unexpected in the calling program.
modulationDir = fullfile(getpref(protocolParams.protocol, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);
for mm = 1:length(protocolParams.modulationNames)
    modulationNames{mm} = sprintf('ModulationStartsStops_%s_%s', protocolParams.modulationNames{mm}, protocolParams.directionNames{mm});
end
if (~strcmp(protocolParams.directionNames{1}(1:6),'MaxMel'))
    error('Direction order not as expected');
end
if (~strcmp(protocolParams.directionNames{2}(1:6),'MaxLMS'))
    error('Direction order not as expected');
end
pathToModFileMel = [modulationNames{1} '.mat'];
pathToModFileLMS = [modulationNames{2} '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));

% Extract the starts and stops that we need
startsLMS = modFileLMS.modulationData.modulation.starts;
stopsLMS = modFileLMS.modulationData.modulation.stops;
startsMel = modFileMel.modulationData.modulation.starts;
stopsMel = modFileMel.modulationData.modulation.stops;

% Put starts stops into cell arrays that can be indexed by stimOrder variable above
stimStarts = {startsLMS startsMel};
stimStops = {stopsLMS stopsMel};
stimFrameDurations = [modFileLMS.modulationData.modulationParams.timeStep modFileMel.modulationData.modulationParams.timeStep];
stimStartsBG = {modFileLMS.modulationData.modulation.background.starts modFileMel.modulationData.modulation.background.starts};
stimStopsBG = {modFileLMS.modulationData.modulation.background.stops modFileMel.modulationData.modulation.background.stops};

% Wait for button press
Speak('Press key to start demo', [], speakRateDefault);
if (~protocolParams.simulate), WaitForKeyPress; end;

fprintf('* <strong>Demo started</strong>\n');
for is = 1:nStimuli
    % Set to background
    ol.setMirrors(stimStartsBG{is}, stimStopsBG{is});
    
    % Adapt to background for 1 minute
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', protocolParams.demoAdaptTimeSecs), [], speakRateDefault);
    if (~protocolParams.simulate), WaitForKeyPress; end;
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], speakRateDefault);
    mglWaitSecs(protocolParams.demoAdaptTimeSecs);
    Speak('Adaptation complete', [], speakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    
    for js = 1:nRepeatsPerStimulus
        ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Repeat: <strong>%g</strong>\n', js);
        Speak(['Press key to start.'], [], 200);
        if (~protocolParams.simulate), WaitForKeyPress; end
        
        fprintf('* Showing stimulus...')
        OLFlicker(ol, stimStarts{is}, stimStops{is}, stimFrameDurations(is), 1);
        fprintf('Done.\n')
    end
end

%% Inform user that we are done
Speak('End of demo.', [], speakRateDefault);

%% Log the demo done
OLSessionLog(protocolParams,mfilename,'StartEnd','end');