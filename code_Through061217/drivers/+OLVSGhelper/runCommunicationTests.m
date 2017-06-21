function runCommunicationTests(OLVSG, UDPtestRepeatsNum)
    
    % Send number of repetitions for each test
    OLVSG.sendParamValue({OLVSG.UDPCOMM_TESTING_REPEATS_NUM, UDPtestRepeatsNum}, ...
         'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', sprintf('telling windows that we will repeat each UDPcomm test %d times', UDPtestRepeatsNum));

    UDPtestsNum = 3;
    delays = zeros(UDPtestsNum,  UDPtestRepeatsNum);

    % Test 1. Mac->Windows: Sending a param value - no value checking
    UDPtestIndex = 1;
    testTitle{UDPtestIndex} = 'Test 1: Mac -> Windows, send param';
    for kRepeat = 1:UDPtestRepeatsNum
        tBefore = mglGetSecs;
        OLVSG.sendParamValue({OLVSG.UDPCOMM_TESTING_SEND_PARAM, kRepeat}, ...
            'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', testTitle{UDPtestIndex});
        delays(UDPtestIndex, kRepeat) = mglGetSecs-tBefore;
    end

    % Test 2. Mac <- Windows: Sending a param value - no value checking
    UDPtestIndex = 2;
    testTitle{UDPtestIndex} = 'Test 2: Mac <- Windows, receive param';
    for kRepeat = 1:UDPtestRepeatsNum
        tBefore = mglGetSecs;
        kk = OLVSG.receiveParamValue(OLVSG.UDPCOMM_TESTING_RECEIVE_PARAM, ...
            'timeOutSecs', 2.0, 'consoleMessage',  testTitle{UDPtestIndex});
        delays(UDPtestIndex, kRepeat) = mglGetSecs-tBefore;
    end

    % Test 3. Mac->Windows: Sending a param value, validating and wait for response
    UDPtestIndex = 3;
    testTitle{UDPtestIndex} = 'Test 3: Mac -> Windows, send param, validate value, wait for response';
    for kRepeat = 1:UDPtestRepeatsNum
        tBefore = mglGetSecs;
        outcome = OLVSG.sendParamValueAndWaitForResponse(...
            {OLVSG.UDPCOMM_TESTING_SEND_PARAM_WAIT_FOR_RESPONSE, 'validCommand1'}, ...
            {OLVSG.UDPCOMM_TESTING_SEND_PARAM_WAIT_FOR_RESPONSE, 'validCommand2'}, ...                   % expected to be received response label
            'timeOutSecs', 5, 'maxAttemptsNum', 3, ...
            'consoleMessage', testTitle{UDPtestIndex});
        delays(UDPtestIndex, kRepeat) = mglGetSecs-tBefore;
    end

    % Display figure with results
    delays = delays*1000;   % tranformt delays units to milliseconds
    %for k = 1:size(delays,2)
    %    fprintf('[%3d]: %2.2f ms,  %2.2f ms,  %2.2f ms\n', k, delays(1,k), delays(2,k), delays(3,k));
    %end
    
    delaysRange = [min(min(delays, [], 2)) max(max(delays, [], 2))];
    range = delaysRange(2)-delaysRange(1);
    delaysRange = [delaysRange(1)-range*0.1 delaysRange(2)+range*0.1];
    if (delaysRange(1) < 0)
        delaysRange(1) = 0;
    end
    
    figure(1); clf;
    meanDelaysForTests_99_99 = prctile(delays, 99.99, 2)
    meanDelaysForTests_99_95 = prctile(delays, 99.95, 2)
    meanDelaysForTests_99_9 = prctile(delays, 99.9, 2)
    meanDelaysForTests_99_5 = prctile(delays, 99.5, 2)
    maxDelaysForTests = max(delays, [], 2);
    for UDPtestIndex = 1:size(delays,1)
        subplot(size(delays,1),1, UDPtestIndex);
        histogram(delays(UDPtestIndex,:), linspace(delaysRange(1), delaysRange(2), 100));
        set(gca, 'XLim', delaysRange, 'FontSize', 12);
        xlabel('round trip delay (msec)', 'FontSize', 14);
        ylabel('number of messages', 'FontSize', 14);
        title(sprintf('%s (N = %d): mean delay (99.5%%) = %2.2f ms, mean delay (99.9%%) = %2.2f ms, max delay = %2.2f ms', testTitle{UDPtestIndex}, size(delays,2), meanDelaysForTests_99_5(UDPtestIndex), meanDelaysForTests_99_9(UDPtestIndex), maxDelaysForTests(UDPtestIndex)), 'FontSize', 12);
    end
    drawnow;
    
    fprintf('\nUDP communication test results OK?\n<strong>Hit enter to proceed with the experiment :</strong>');
    pause;
    OLVSG.sendParamValue({OLVSG.WAIT_STATUS, 'Proceed with experiment'}, ...
        'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'telling windows to proceed with experiment');
end