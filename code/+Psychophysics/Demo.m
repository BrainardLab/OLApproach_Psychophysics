function protocolParams = Demo(protocolParams)
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
% Update Session Log file
protocolParams = OLSessionLog(protocolParams,mfilename,'StartEnd','start');


% Setup and prompt user for info
SpeakRateDefault = getpref(protocolParams.approach, 'SpeakRateDefault');

% Parameters

protocolParams.adaptTimeSecs = 0.9999999; % 1 minute
protocolParams.frameDurationSecs = 1/64;
protocolParams.ISISecs = 1;
protocolParams.NRepeatsPerStimulus = 3;
protocolParams.NStimuli = 2;

% Assemble the modulations
modulationDir =  fullfile(getpref(protocolParams.approach, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);

d = ModulationParamsDictionary(protocolParams);
modulationParams = d('Modulation-PulseMaxLMS_3s_MaxContrast3sSegment');
startsStopsCacheFileNames{1} = modulationParams.direction;

modulationParams = d('Modulation-PulseMaxMel_3s_MaxContrast3sSegment');
startsStopsCacheFileNames{2} = modulationParams.direction;


pathToModFileLMS = sprintf('%s.mat', startsStopsCacheFileNames{1});  %  ['Direction_' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];
pathToModFileMel = sprintf('%s.mat', startsStopsCacheFileNames{2});  % ['Direction_' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];
%pathToModFileLightFlux = ['Direction_' num2str(protocolParams.observerAgeInYrs) '_' protocolParams.observerID '_' protocolParams.todayDate '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));
%modFileLightFlux = load(fullfile(modulationDir, pathToModFileLightFlux));

startsLMS = modFileLMS.modulationData.modulation.starts;
stopsLMS = modFileLMS.modulationData.modulation.stops;
startsMel = modFileMel.modulationData.modulation.starts;
stopsMel = modFileMel.modulationData.modulation.stops;
%startsLightFlux = modFileLightFlux.modulationData.modulation.starts;
%stopsLightFlux = modFileLightFlux.modulationData.modulation.stops;

%stimLabels = {'LightFlux', 'MaxLMS', 'MaxMel'};
stimLabels = {'MaxLMS', 'MaxMel'};
%stimStarts = {startsLightFlux startsLMS startsMel};
stimStarts = {startsLMS startsMel};
%stimStops = {stopsLightFlux stopsLMS stopsMel};
stimStops = {stopsLMS stopsMel};
%stimStartsBG = {modFileLightFlux.modulationData.modulation.background.starts modFileLMS.modulationData.modulation.background.starts modFileMel.modulationData.modulation.background.starts};
stimStartsBG = {modFileLMS.modulationData.modulation.background.starts modFileMel.modulationData.modulation.background.starts};
%stimStopsBG = {modFileLightFlux.modulationData.modulation.background.stops modFileLMS.modulationData.modulation.background.stops modFileMel.modulationData.modulation.background.stops};
stimStopsBG = { modFileLMS.modulationData.modulation.background.stops modFileMel.modulationData.modulation.background.stops};

% Wait for button press
Speak('Press key to start demo', [], SpeakRateDefault);
%WaitForKeyPress;

fprintf('* <strong>Experiment started</strong>\n');

% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate);

for is = 1:protocolParams.NStimuli
    % Set to background
    ol.setMirrors(stimStartsBG{is}, stimStopsBG{is});
    
    % Adapt to background for 1 minute
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', protocolParams.adaptTimeSecs), [], SpeakRateDefault);
   % WaitForKeyPress;
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(protocolParams.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    toc;
    
    for js = 1:protocolParams.NRepeatsPerStimulus
        ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Repeat: <strong>%g</strong>\n', js);
        Speak(['Press key to start.'], [], 200);
        %WaitForKeyPress;
        
        fprintf('* Showing stimulus...')
        OLFlicker(ol, stimStarts{is}, stimStops{is}, protocolParams.frameDurationSecs, 1);
        fprintf('Done.\n')
    end
end

% Inform user
Speak('End of demo.', [], SpeakRateDefault);
protocolParams = OLSessionLog(protocolParams,mfilename,'StartEnd','end');