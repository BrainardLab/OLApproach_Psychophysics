function isBeingTracked = eyeTrackerCheck(OLVSG)
    % isBeingTracked = OLVSGEyeTrackerCheck
    % This function makes sure that the EyeTracker is successfully tracking
    % the subject's eye.
    %
    % We want to get 5 good data points for 5 seconds
    timeCheck = 5;
    dataCheck = 5;
    
    OLVSG.flashQueue()
    WaitSecs(1);
    
    % === Send the startEyeTrackerCheck ===================================
    OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'startEyeTrackerCheck'}, ...
        'timeOutSecs', 8.0, 'maxAttemptsNum', 1, 'consoleMessage', 'Start eye tracking check.');
    % =====================================================================
 
    tStart = mglGetSecs;
    while (mglGetSecs-tStart <= timeCheck)
        % Collecting checking data
    end

    % === Retrieve the number of eye tracking data points =================
    numTrackedData = OLVSG.receiveParamValue(OLVSG.EYE_TRACKER_DATA_POINTS_NUM,  ...
        'timeOutSecs', 6.0, 'consoleMessage', 'Waiting for eye tracker data');
    % =====================================================================
  
    % Clear the buffer
    OLVSG.flashQueue();
    
    if (numTrackedData >= dataCheck)
        isBeingTracked = true;
        % ====  Send the eye tracker status ===============================
        OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'isTracking'}, ...
            'timeOutSecs', 4, 'consoleMessage', 'Eye tracking check was successful.');
        % =================================================================
    else
        isBeingTracked = false;
        % ====  Send the eye tracker status ===============================
        OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'isNotTracking'}, ...
            'timeOutSecs', 4, 'consoleMessage', 'Eye tracking check failed');
        % =================================================================
    end
end