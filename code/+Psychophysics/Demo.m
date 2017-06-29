function Demo(protocolParams)
% Demo
%
% Description:
%   Simple program for demo of MaxMel/MaxLMS pulses
%
% 7/7/16    ms      Wrote it.

% ALL OF THE PARAMETERS NEED TO COME OUT OF HERE.
% SHOULD THE ol OBJECT BE OPENED OR PASSED?  PASSED
% I WOULD THINK.

% SHOULD BE A switch on params.protocol, so different protocols within
% Psychophysics approach can do different sorts of things.

% Setup and prompt user for info
SpeakRateDefault = getpref('OneLight', 'SpeakRateDefault');
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'MELA_xxxx');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

% Parameters

protocolParams.adaptTimeSecs = 3.333334; % 1 minute
protocolParams.frameDurationSecs = 1/64;
protocolParams.ISISecs = 5;
protocolParams.NRepeatsPerStimulus = 3;
protocolParams.NStimuli = 3;

% Assemble the modulations
modulationDir = fullfile(getpref(protocolParams.approach, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);
pathToModFileLMS = ['Modulation-PulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];
pathToModFileMel = ['Modulation-PulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment-' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];
pathToModFileLightFlux = ['Modulation-PulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment-' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];

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

stimLabels = {'LightFlux', 'MaxLMS', 'MaxMel'};
%stimLabels = {'MaxLMS', 'MaxMel'};
stimStarts = {startsLightFlux startsLMS startsMel};
%stimStarts = {startsLMS startsMel};
stimStops = {stopsLightFlux stopsLMS stopsMel};
%stimStops = {stopsLMS stopsMel};
stimStartsBG = {modFileLightFlux.modulationObj.modulation.background.starts modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts};
%stimStartsBG = {modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts};
stimStopsBG = {modFileLightFlux.modulationObj.modulation.background.stops modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops};
%stimStopsBG = { modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops};

% Wait for button press
Speak('Press key to start demo', [], SpeakRateDefault);
WaitForKeyPress;
fprintf('* <strong>Experiment started</strong>\n');

% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate);

for is = 1:protocolParams.NStimuli
    % Set to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 1 minute
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', protocolParams.adaptTimeSecs), [], SpeakRateDefault);
    WaitForKeyPress;
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(protocolParams.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    toc;
    
    for js = 1:protocolParams.NRepeatsPerStimulus
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Repeat: <strong>%g</strong>\n', js);
        Speak(['Press key to start.'], [], 200);
        WaitForKeyPress;
        
        fprintf('* Showing stimulus...')
        OLFlicker(ol, stimStarts{is}, stimStops{is}, protocolParams.frameDurationSecs, 1);
        fprintf('Done.\n')
    end
end

% Inform user
Speak('End of demo.', [], SpeakRateDefault);