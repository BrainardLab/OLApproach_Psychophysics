% Mac client sending UDP communication requests to
% OLFlickerSensitivityVSGPupillometryOnLine.m (Windows)
% These two programs must be run in tanden to conduct the pupillometry experiments.
% A robust UDP communication is handled by classes UDPcommunicator and
% OLVSGcommunicator found in the BrainardLabToolbox. These classes can
% interface with lowlevel UDP commands either using the brainard lab
% matlabUDP mex file or Matlab's native udp

% 03/01/2016   NPC  Wrote it (by modifying ModulationTrialSequencePupillometryNulled)
% 03/04/2016   NPC  Added UDP communication tests
% 10/26/2016   NPC  Added ability to record temperature

function params = ModulationTrialSequencePupillometryNulledOnLine(exp)

% Halt here until user says that windows client is up and running
fprintf('\n\n<strong>%s</strong> Hit enter once the windowsClient is up and running....\n', mfilename);
pause;


% Query user whether to take temperature measurements
takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
if (takeTemperatureMeasurements ~= true) && (takeTemperatureMeasurements ~= 1)
    takeTemperatureMeasurements = false;
else
    takeTemperatureMeasurements = true;
end

% Attempt to open the LabJack temperature sensing device

if (takeTemperatureMeasurements)
    % Gracefully attempt to open the LabJack
    [takeTemperatureMeasurements, quitNow, theLJdev] = OLCalibrator.OpenLabJackTemperatureProbe(takeTemperatureMeasurements);
    if (quitNow)
        return;
     end
else
     theLJdev = [];
end        
[runCommTest, commTestRepeats] = OLVSGhelper.getCommTestParams();

% Setup parameters and configure block of trials
[params, block] = OLVSGhelper.initParamsAndGenerateBlock(exp);

% Instantiate an OLVSGcommunicator object to manage the UDP connection
% between the mac and the windows machine
OLVSG = OLVSGcommunicator( ...
    'signature', 'MacSide', ...           % a label indicating the host, used to for user-feedback
    'localIP', params.macHostIP, ...    % required: the IP of this computer
    'remoteIP', params.winHostIP, ...    % required: the IP of the computer we want to conenct to
    'udpPort', params.udpPort, ...      % optional, with default value: 2007
    'verbosity', 'max' ...                % optional, with default value: 'normal', and possible values: {'none', 'min', 'normal', 'max'},
    );

% == Wake the Windows machine up ======================================
OLVSG.sendParamValue({OLVSG.WAIT_STATUS, 'Wake Up'}, ...
    'timeOutSecs', 4.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending wake up message');


% == Inform Windows whether we will be running communication tests
OLVSG.sendParamValue({OLVSG.UDPCOMM_TESTING_STATUS, runCommTest}, ...
    'timeOutSecs', 4.0, 'maxAttemptsNum', 1, 'consoleMessage', 'telling windows whether we will run UDPcomm tests');

% Run the communication tests
if (runCommTest)
    OLVSGhelper.runCommunicationTests(OLVSG, commTestRepeats);
end


fprintf('\n* Creating keyboard listener\n');
mglListener('init');

% generate sounds
[stopSound, startSound, hintSound] = OLVSGhelper.generateSounds();

% Create the OneLight object.
% This makes sure we are talking to OneLight.
ol = OneLight;

% Make sure our input and output pattern buffers are setup right.
ol.InputPatternBuffer = 0;
ol.OutputPatternBuffer = 0;

% Set the background to the 'idle' background appropriate for this trial.
fprintf('- Setting mirrors to background\n');
ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trial

% == Send param values ================================================
OLVSG.sendParamValue({OLVSG.PROTOCOL_NAME,       params.protocolName}, ...
    'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending protocol name');
OLVSG.sendParamValue({OLVSG.OBSERVER_ID,         params.obsID}, ...
    'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending observer ID');
OLVSG.sendParamValue({OLVSG.OBSERVER_ID_AND_RUN, params.obsIDAndRun}, ...
    'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending observer ID and run');
OLVSG.sendParamValue({OLVSG.NUMBER_OF_TRIALS,    params.nTrials}, ...
    'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending number of trials');
OLVSG.sendParamValue({OLVSG.STARTING_TRIAL_NO,   params.whichTrialToStartAt}, ...
    'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending which trial to start at');
OLVSG.sendParamValue({OLVSG.OFFLINE,             params.VSGOfflineMode}, ...
    'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending VSGOfflineMode');


% == Wait for up to 30 seconds to receive the signal that the pre-trial diagnostic loop video recording has finished ========
fprintf('- Waiting for the pre-trial diagnostic video to finish recording ... ');
videoRecordingStatus = OLVSG.receiveParamValue(OLVSG.DIAGNOSTIC_VIDEO_RECORDING_STATUS,  ...
    'timeOutSecs', 30.0, 'consoleMessage', 'Pre-trial video recording finished ?');
fprintf('- Done.\n');


if (strcmp(videoRecordingStatus, 'sucessful'))
    fprintf('- Done.\n');
else
    fprintf(2,'- Failed. Exiting now.\n');
    Speak('Windows failed to record pre-trial diagnostic video. Exiting now.');
    
    ListenChar(0);
    
    % Turn all mirrors off
    ol.setMirrors(block(trial).data.startsBG',  block(trial).data.stopsBG'); % Use first trialol.setAll(false);
    
    OLVSG.shutDown();
    return;
end

% Initialize data structure to be used to obtain the data for all trials
data = struct(...
    'diameter', -1, ...
    'time', -1, ...
    'time_inter', -1, ...
    'average_diameter', -1, ...
    'ratioInterupt', -1 ...
    );

dataStruct = repmat(data, params.nTrials, 1);
events = struct();

% Run the trial loop.
for trial = params.whichTrialToStartAt:params.nTrials
    %% Re-set the mirrors to the background to prevent OneLight from
    % blinking the mirrors to zero during the chekcResume below.
    ol.setMirrors(block(trial).data.startsBG',  block(trial).data.stopsBG');
    
    %% Insert a break for the subject
    resume = false;
    if trial == 1
        gamePad = GamePad();
        Speak('Press a key when you are ready to start experiment.');
        while (resume == false)
            
            action = gamePad.read();
            % If a key was pressed, get the key and exit.
            switch (action)
                case gamePad.buttonChange
                    sound(hintSound.y, hintSound.fs);
                    resume = true;
            end
        end
    end
    
    breakTrials = (params.BreakModulus:params.BreakModulus:100)+1;
        
    if ismember(trial, breakTrials)
        gamePad = GamePad();
        resume = false;
        Speak('Take a break now. Press a key when you are ready to resume.');
        while (resume == false)
            pause(.1);
            action = gamePad.read();
            % If a key was pressed, get the key and exit.
            switch (action)
                case gamePad.buttonChange
                    %sound(hintSound.y, hintSound.fs);
                    resume = true;
                    sound(hintSound.y, hintSound.fs);
            end
        end%
        
        % Enforce a break here
        Speak('Starting now. Focus on stimulus for 2 minutes.');
        mglWaitSecs(30);
    end

    % Report the trial number to the screen. Reporting the option by voice
    % is currently de-activated
    fprintf('* Start trial %i/%i - %s, %.2f Hz.\n', trial, params.nTrials, block(trial).direction, block(trial).carrierFrequencyHz);
    %Speak(['Trial ' num2str(trial)  ' of ' num2str(params.nTrials)]);
    
    abort = false;

    % This variable defines when there is checking for the quality of pupil
    % tracking before proceeding with the experiment.
    checkTrials = 1:params.BreakModulus:100;

    if ismember(trial, checkTrials)
        readyToResume = false; isBeingTracked = false; params.run = false;
        % Check the tracking function of VET system
        while (params.run == false)
            
            % Check whether the user is good to resume
            [readyToResume, abort] = OLVSGhelper.checkResume(readyToResume, hintSound);
            
            % ==  Send user ready status ==================================
            OLVSG.sendParamValue({OLVSG.USER_READY_STATUS, 'user ready to move on'}, ...
                'timeOutSecs', 8.0, 'maxAttemptsNum', 1, 'consoleMessage', 'User input acquired');
            
            % == Wait to receive the userReady (continue or abort) ========
            continueCheck = OLVSG.receiveParamValue(OLVSG.USER_READY_STATUS,  ...
                'timeOutSecs', 8.0, 'consoleMessage', 'Continue checking ?');
            
            if strcmp(continueCheck, 'abort');
                abort = true;
            elseif strcmp(continueCheck, 'continue');
                % Let's make sure that the eye is being tracked
                isBeingTracked = OLVSGhelper.eyeTrackerCheck(OLVSG);
            else
                error('Unknown continueCheck value: ''%s''\n', continueCheck);
            end
            
            if (abort == true)
                % If not, we break out.
                pause(5);
                Speak('Could not track.');
                break;
            end
            
            % If we have to redo the tracking, play a tone
            if (isBeingTracked == false)
                sound(stopSound.y, stopSound.fs);
                Speak('Cannot track eye position. Please open your eyes and hold still.');
            end
            
            % Is everything OK? Then proceed.
            if (readyToResume == true && isBeingTracked == true)
                params.run = true;
            end
        end
    end
        
    % Abort if true
    if (abort == true)
        break;
    end
        
    % === Send the 'startTracking' command ============================
    OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'startTracking'}, ...
        'timeOutSecs', 5, 'maxAttemptsNum', 3, ...
        'consoleMessage', 'Sending request to start tracking');
    
    % Launch into OLPDFlickerSettings.
    events(trial).tTrialStart = mglGetSecs;
    [~, events(trial).t] = modulationTrialSequenceFlickerStartsStops(ol, trial, block, params.timeStep, 1);
    events(trial).tTrialEnd = mglGetSecs;
    
    % Set back to background
    ol.setMirrors(block(trial).data.startsBG',  block(trial).data.stopsBG');
    
    % === Send the 'stopTracking' command and wait for the trial outcome ====
    trialOutcome = OLVSG.sendParamValueAndWaitForResponse(...
        {OLVSG.EYE_TRACKER_STATUS, 'stopTracking'}, ...
        {OLVSG.TRIAL_OUTCOME}, ...                             % expected response label
        'timeOutSecs', 5, 'maxAttemptsNum', 3, ...
        'consoleMessage', 'Sending request to stop tracking')
    
    if (params.VSGOfflineMode)
        % === Send the start saving data command and wait until windows says it is done
        OLVSG.sendParamValueAndWaitForResponse(...
            {OLVSG.EYE_TRACKER_STATUS, 'startSavingOfflineData'}, ...
            {OLVSG.EYE_TRACKER_STATUS, 'finishedSavingOfflineData'}, ...
            'timeOutSecs', Inf, ...
            'consoleMessage', 'Sending request to start saving offline data'...
            );
    end
    
    % Save the data structure
    if (params.VSGOfflineMode == false)
        % Set the mirrors to the background
        ol.setMirrors(block(trial).data.startsBG', block(trial).data.stopsBG');
        
        % Get the data
        [time, diameter, good_counter, interruption_counter, time_inter] = ...
            OLVSGhelper.transferData(OLVSG, trial);
        
        % Calculate Some statistics on how good the measuremnts were
        good_counter = good_counter - 1;
        interruption_counter = interruption_counter - 1;
        ratioInterupt = (interruption_counter/(interruption_counter+good_counter));
        average_diameter = mean(diameter)*ones(size(time));
        
        % Assign what we obtain to the data structure.
        dataStruct(trial).diameter = diameter;
        dataStruct(trial).time = time;
        dataStruct(trial).time_inter = time_inter;
        dataStruct(trial).average_diameter = average_diameter;
        dataStruct(trial).ratioInterupt = ratioInterupt;
    end
    
    if strcmp(block(trial).modulationMode, 'AM')
        dataStruct(trial).frequencyEnvelope = block(trial).envelopeFrequencyHz;
        dataStruct(trial).phaseEnvelope = block(trial).carrierPhaseDeg;
        dataStruct(trial).modulationMode = block(trial).modulationMode;
    end
    
    if strcmp(block(trial).modulationMode, 'BG')
        dataStruct(trial).frequencyEnvelope = 0;
        dataStruct(trial).phaseEnvelope = 0;
        dataStruct(trial).modulationMode = block(trial).modulationMode;
    end
    
    if strcmp(block(trial).modulationMode, 'FM')
        dataStruct(trial).frequencyEnvelope = 0;
        dataStruct(trial).phaseEnvelope = 0;
        dataStruct(trial).modulationMode = block(trial).modulationMode;
    end
    dataStruct(trial).modulationMode = block(trial).modulationMode;
    
    if (params.VSGOfflineMode == true)
        dataStruct(trial).frequencyCarrier = block(trial).carrierFrequencyHz;
        dataStruct(trial).phaseCarrier = block(trial).carrierPhaseDeg;
        dataStruct(trial).direction = block(trial).direction;
        dataStruct(trial).contrastRelMax = block(trial).contrastRelMax;
        
        if ~isempty(strfind(block(trial).modulationMode, 'pulse'))
            dataStruct(trial).frequencyEnvelope = 0;
            dataStruct(trial).phaseEnvelope = 0;
            dataStruct(trial).modulationMode = block(trial).modulationMode;
            dataStruct(trial).phaseRandSec = block(trial).phaseRandSec;
            dataStruct(trial).stepTimeSec = block(trial).stepTimeSec;
            dataStruct(trial).preStepTimeSec = block(trial).preStepTimeSec;
        end
    end
    
    % Measure the temperature
    if (takeTemperatureMeasurements)
        [status, dataStruct(trial).temperature] = theLJdev.measure();
        fprintf('OneLight temperatures: %2.1f %2.1f\n', dataStruct(trial).temperature(1), dataStruct(trial).temperature(2));
    end
    
    % Clear the variables to get ready for the trial.
    clear time;
    clear diameter;
    clear good_counter;
    clear interruption_counter;
    clear time_inter;
end % for trial

tBlockEnd = mglGetSecs;

% == Wait for up to 30 seconds to receive the signal that the post-trial diagnostic loop video recording has finished ========
fprintf('- Waiting for the post-trial diagnostic video to finish recording ... ');
videoRecordingStatus = OLVSG.receiveParamValue(OLVSG.DIAGNOSTIC_VIDEO_RECORDING_STATUS,  ...
    'timeOutSecs', 30.0, 'consoleMessage', 'Post-trial video recording finished ?');

if (strcmp(videoRecordingStatus, 'sucessful'))
    fprintf('- Done.\n');
else
    fprintf(2,'- Failed. But will continue. \n');
end

fprintf('- Done with block.\n');
Speak('End of Experiment');
ListenChar(0);

% Turn all mirrors off
ol.setMirrors(block(trial).data.startsBG',  block(trial).data.stopsBG'); % Use first trialol.setAll(false);

% Tack data that we want for later analysis onto params structure.  It then
% gets passed back to the calling routine and saved in our standard place.
params.dataStruct = dataStruct;

% Toss the OLCache and OneLight objects because they are really only ephemeral.
params = rmfield(params, {'olCache'});

OLVSG.shutDown();
end
