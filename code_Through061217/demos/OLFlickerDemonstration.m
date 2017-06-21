DEBUG = false;
clc; % Clear the screen
% Define a few set parameters
theObserverAge = 32;
calType = 'OLBoxCShortCableShortCableAEyePieceStubby1';
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';

% Load the calibration type
cal = LoadCalFile(calType);

% Setup the cache.
olCache = OLCache(cacheDir, cal);
theDirections = {'LightFlux', 'LMSDirected', 'LMPenumbraDirected', 'MelanopsinDirectedPenumbralIgnore' 'LMinusMDirected' 'SDirected'};
theDirectionLabels = {'Light flux', 'L+M+S', 'L*+M* [penumbral cones]', 'Melanopsin', 'L-M', 'S'};
theAvailableCacheFiles = dir('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-*.mat');
theFrequencies = [0.5 1 2 4 8 16 32 64];
thePeriodLengths = 1./theFrequencies;
theWaitTimes = thePeriodLengths/2;

fprintf('\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
fprintf('\nAvailable modulations  [Select with number keys]');
for i = 1:length(theDirections)
    fprintf('\n* (%g) %s', i, theDirectionLabels{i});
end
fprintf('\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
fprintf('\nAvailable frequencies [Change with right and left arrows]');
for i = 1:length(theFrequencies)
    fprintf('\n* %g Hz', theFrequencies(i));
end

% Load the cache data.
fprintf('\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
fprintf('\nLoading the cache and calculating starts/and stops...');
for cacheIndex = 1:length(theDirections)
    [cacheData{cacheIndex},isStale] = olCache.load(['Cache-' theDirections{cacheIndex}]);
    assert(~isStale,'Cache file is stale, aborting.');
    bgPrimary = cacheData{cacheIndex}.data(theObserverAge).backgroundPrimary;
    modPosPrimary = cacheData{cacheIndex}.data(theObserverAge).backgroundPrimary+cacheData{cacheIndex}.data(theObserverAge).differencePrimary;
    modNegPrimary = cacheData{cacheIndex}.data(theObserverAge).backgroundPrimary-cacheData{cacheIndex}.data(theObserverAge).differencePrimary;
    
    [bgStarts{cacheIndex}, bgStops{cacheIndex}] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgPrimary));
    [modPosStarts{cacheIndex}, modPosStops{cacheIndex}] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, modPosPrimary));
    [modNegStarts{cacheIndex}, modNegStops{cacheIndex}] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, modNegPrimary));
end
fprintf('Done!\n');

% Initialize the OneLight and set to background
if ~DEBUG
    ol = OneLight;
    ol.setMirrors(bgStarts{cacheIndex}, bgStops{cacheIndex});
end

% Setting some parameters for the loop
keepRunning = true;
currMod = 1;
currFreq = 1;
mglGetKeyEvent;
fprintf('\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
fprintf('\nStarting now - PRESS Q TO QUIT...');

while keepRunning
    fprintf('\n>> Currently: %s @ %g Hz', theDirectionLabels{currMod}, theFrequencies(currFreq));
    
    if ~DEBUG
        ol.setMirrors(modNegStarts{currMod}, modNegStops{currMod});
        mglWaitSecs(theWaitTimes(currFreq));
        ol.setMirrors(modPosStarts{currMod}, modPosStops{currMod});
        mglWaitSecs(theWaitTimes(currFreq));
    end
    
    tmp = mglGetKeyEvent;
    if ~isempty(tmp);
        key = tmp;
        if (str2num(key.charCode) == 1)
            currMod = 1;
        end
        if (str2num(key.charCode) == 2)
            currMod = 2;
        end
        if (str2num(key.charCode) == 3)
            currMod = 3;
        end
        if (str2num(key.charCode) == 4)
            currMod = 4;
        end
        if (str2num(key.charCode) == 5)
            currMod = 5;
        end
        if (str2num(key.charCode) == 6)
            currMod = 6;
        end
        if (strcmp(key.charCode, 'q'))
            keepRunning = false;
        end
        if (strcmp(key.charCode, 'a'))
            currFreq = currFreq-1;
        end
        if (strcmp(key.charCode, 's'))
            currFreq = currFreq+1;
        end
        if currFreq < 1
            currFreq = length(theFrequencies);
        end
        if currFreq > length(theFrequencies)
            currFreq = 1;
        end
    end
end

fprintf('\n*** Please issue shutdown command: ***');
fprintf('\n    >> ol.shutdown;\n\n')