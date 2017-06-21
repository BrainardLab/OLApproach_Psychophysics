function [obj keyEvents] = doTrial(obj, ol)
% expt = doTrial(obj)
%
% Description: Does a trial

% Set up some sounds
fs = 20000;
durSecs = 0.1;
t = linspace(0, durSecs, durSecs*fs);
yChangeUp = [sin(880*2*pi*t)];
yChangeDown = [sin(440*2*pi*t)];

switch obj.experimentType
    case '2ifc'
        numIterations = 1;
        % First interval
        currIdx1 = obj.interval1_paramsCurrIndex;
        starts1 = obj.interval1_olStarts{currIdx1};
        stops1 = obj.interval1_olStops{currIdx1};
        
        % Second interval
        currIdx2 = obj.interval2_paramsCurrIndex;
        starts2 = obj.interval2_olStarts{currIdx2};
        stops2 = obj.interval2_olStops{currIdx2};
        
        if obj.interval1_isFlicker
            sound(yChangeUp, fs);
            % Show the flicker for interval 1
            t1 = OLFlickerStartsStopsOO(ol, starts1, stops1, 1/obj.olRefreshRate, numIterations, false);
            sound(yChangeDown, fs);
        else
            % Show the static settings and wait
            ol.setMirrors(starts1', stops1');
            mglWaitSecs(obj.interval1_duration);
        end
        
        % Set to background
        
        if obj.isi > 0
            ol.setMirrors(obj.bg_olStarts', obj.bg_olStops');
            % Wait for the ISI
            mglWaitSecs(obj.isi);
        end
        
        if obj.interval2_isFlicker
            sound(yChangeUp, fs);
            % Show the flicker for interval 1
            t2 = OLFlickerStartsStopsOO(ol, starts2, stops2, 1/obj.olRefreshRate, numIterations, false);
            sound(yChangeDown, fs);
        else
            % Show the static settings and wait
            ol.setMirrors(starts2', stops2');
            mglWaitSecs(obj.interval2_duration);
        end
        
        % Back to background
        ol.setMirrors(obj.bg_olStarts', obj.bg_olStops');
    case 'adjustment'
        numIterations = 1;
        % First interval
        currIdx1 = obj.interval1_paramsCurrIndex;
        starts1 = obj.interval1_olStarts{currIdx1};
        stops1 = obj.interval1_olStops{currIdx1};
        
        % Append the post-stimulus background. That way, we can also check
        % for key presses in that period
        nRepts = floor(obj.isi*obj.olRefreshRate);
        appendStarts = repmat(obj.bg_olStarts, nRepts, 1);
        appendStops = repmat(obj.bg_olStops, nRepts, 1);
        
        starts1 = [starts1 appendStarts'];
        stops1 = [stops1 appendStops'];
        
        if obj.interval1_isFlicker
            % Show the flicker for interval 1
            [t1 keyEvents] = OLFlickerStartsStopsOO(ol, starts1, stops1, 1/obj.olRefreshRate, numIterations, true);
        else
            % Show the static settings and wait
            ol.setMirrors(starts1', stops1');
            mglWaitSecs(obj.interval1_duration);
        end
        
        
end

