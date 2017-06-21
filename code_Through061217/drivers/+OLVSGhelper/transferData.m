function [time, diameter, good_counter, interruption_counter, time_inter] = transferData(OLVSG, trialNo)
% Get the data from the VSG box

    % === Send begin transfer request and wait for acknowledgment =========
    OLVSG.sendParamValueAndWaitForResponse(...
        {OLVSG.DATA_TRANSFER_STATUS, 'begin transfer'}, ...    % transmitted message
        {OLVSG.DATA_TRANSFER_STATUS, 'begin transfer'}, ...    % expected to be received message
        'timeOutSecs', 2.0, 'maxAttemptsNum', 1, ...
        'consoleMessage', sprintf('Sending request to begin data transfer for trial %d', trialNo));
    % =====================================================================
            
    good_counter = 0;

    % Clear and initialize some variables
    clear diameter;
    clear time;
    clear time_inter;
    interruption_counter = 0;
    diameter(1) = 0;
    time(1) = 0;
    time_inter(1) = 0;

    % === Wait to receive the number of data points to be transfered ======
    nDataPoints = OLVSG.receiveParamValue(OLVSG.DATA_TRANSFER_POINTS_NUM, ...
        'timeOutSecs', 2.0);
    % =====================================================================

    fprintf('OLVSGTransferData: The number of data points is %d\n', nDataPoints);       
    % Iterate over the data points
    for i = 1:nDataPoints

        % == Send request to trasfer data point i, and wait to receive that point
        firstSampleTimeStamp = OLVSG.sendParamValueAndWaitForResponse(...
            {OLVSG.DATA_TRANSFER_REQUEST_FOR_POINT, i}, ...
            {OLVSG.DATA_FOR_POINT}, ...
            'timeOutSecs', 2, ...
            'consoleMessage', sprintf('Sending request for data point %d and waiting for response', i) ...
        );
        % =================================================================

        parsedline = allwords(firstSampleTimeStamp, ' ');
        diam = str2double(parsedline{1});
        ti = str2double(parsedline{2});
        isinterruption = str2double(parsedline{3});
        interrupttime = str2double(parsedline{4});
        if (isinterruption == 0)
            good_counter = good_counter+1;
            diameter(good_counter) = diam;
            time(good_counter) = ti;
        elseif (isinterruption == 1)
            interruption_counter = interruption_counter + 1;
            time_inter(interruption_counter) = interrupttime;
        end
    end   

    % == Send the end transfer request  ===================================
    OLVSG.sendParamValue({OLVSG.DATA_TRANSFER_STATUS, 'end transfer'}, ...
        'consoleMessage', sprintf('Sending request to end data transfer for trial %d', trialNo));
    % ==== NEW ===  Send the end transfer request  ========================
end