function [keyEvents, t, counter] = modulationTrialSequenceFlickerStartsStops(ol, trial, block, frameDurationSecs, numIterations)
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
%starts = block(trial).data.starts';
%stops = block(trial).data.stops';

%keyPress = [];

% Flag whether we're checking the keyboard during the flicker loop.
%checkKB = isinf(numIterations);

% Counters to keep track of which of the stops to display and which
% iteration we're on.
iterationCount = 0;
setCount = 0;

numstops = size(block(trial).data.starts, 2);

t = zeros(1, numstops);
i = 0;

% This is the time of the stops change.  It gets updated everytime
% we apply new mirror stops.
mileStone = mglGetSecs + frameDurationSecs;

keyEvents = [];
while iterationCount < numIterations
    if mglGetSecs >= mileStone;
        i = i + 1;
        
        % Update the time of our next switch.
        mileStone = mileStone + frameDurationSecs;
        
        % Update our stops counter.
        setCount = mod(setCount + 1, numstops);
        
        % If we've reached the end of the stops list, iterate the
        % counter that keeps track of how many times we've gone through
        % the list.
        if setCount == 0
            iterationCount = iterationCount + 1;
            setCount = numstops;
        end
        
        % Send over the new stops.
        t(i) = mglGetSecs;
        counter(i) = setCount;
        ol.setMirrors(block(trial).data.starts(:, setCount)', block(trial).data.stops(:, setCount)');
    end
end
end