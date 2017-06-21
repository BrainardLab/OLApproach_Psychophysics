function [t keyEvents] = OLFlickerStartsStopsOO(ol, starts, stops, frameDurationSecs, numIterations, checkKB)

% Counters to keep track of which of the stops to display and which
% iteration we're on.
iterationCount = 0;
setCount = 0;

numSettings = size(starts, 2);
t = zeros(1, numSettings);
i = 1;

% This is the time of the stops change.  It gets updated everytime
% we apply new mirror stops.
mileStone = mglGetSecs + frameDurationSecs;

keyEvents = [];
m = 1;
%tic
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
        keyEvents = [keyEvents tmp];
    end
    
end
%toc

% Only return most recent key event
if ~isempty(keyEvents)
    keyEvents = keyEvents(end);
end