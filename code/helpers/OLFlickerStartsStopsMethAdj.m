function [keyEvents, t, keyToReturn] = OLFlickerStartsStopsMethAdj(ol, starts, stops, frameDurationSecs, numIterations, checkKB)
% OLFlicker - Flickers the OneLight.
%
% Syntax:
% keyPress = OLFlicker(ol, stops, frameDurationSecs, numIterations)
%
% Description:
% Flickers the OneLight using the passed stops matrix until a key is
% pressed or the number of iterations is reached.
%
% Input:
% ol (OneLight) - The OneLight object.
% stops (1024xN) - The normalized [0,1] mirror stops to loop through.
% frameDurationSecs (scalar) - The duration to hold each setting until the
%     next one is loaded.
% numIterations (scalar) - The number of iterations to loop through the
%     stops.  Passing Inf causes the function to loop forever.
%
% Output:
% keyPress (char|empty) - If in continuous mode, the key the user pressed
%     to end the script.  In regular mode, this will always be empty.

% Setup character listening.
mglGetKeyEvent;


try
    %keyPress = [];
    
    % Flag whether we're checking the keyboard during the flicker loop.
    %checkKB = isinf(numIterations);
    
    % Make sure our input and output pattern buffers are setup right.
    ol.InputPatternBuffer = 0;
    ol.OutputPatternBuffer = 0;
    
    % Counters to keep track of which of the stops to display and which
    % iteration we're on.
    iterationCount = 0;
    setCount = 0;
    
    numSettings = size(stops, 2);
    
    t = zeros(1, numSettings);
    i = 1;
    
    % This is the time of the stops change.  It gets updated everytime
    % we apply new mirror stops.
    mileStone = mglGetSecs + frameDurationSecs;
    %tic;
    
    keyEvents = [];
    m = 1;
    while iterationCount < numIterations
         if mglGetSecs >= mileStone;
            t(i) = mglGetSecs;
            i = i + 1;
            
            % Update the time of our next switch.
            mileStone = mileStone + frameDurationSecs;
            
            % Update our stops counter.
            setCount = mod(setCount + 1, numSettings);
            
            % If we've reached the end of the stops list, iterate the
            % counter that keeps track of how many times we've gone through
            % the list.
            if setCount == 0

                iterationCount = iterationCount + 1;
            end
            
            % Send over the new stops.
            ol.setMirrors(starts(:, setCount+1), stops(:, setCount+1));
        end
        
        % If we're using keyboard mode, check for a keypress.
        if checkKB
            tmp = mglGetKeyEvent;
            if ~isempty(tmp);
                keyToReturn = tmp;
                %break;
                %numIterations = iterationCount + 1;
            end
        end
    end
    %toc;


catch e
    ListenChar(0);
    rethrow(e);
end
