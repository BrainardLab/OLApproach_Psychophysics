%% Demo MeLMSens_SteadyAdapt protocol
%
% Stimuli to demonstrate:
%  Single modulation
%   - Mel or LMS directed background
%   - Low or high stimulation in background
%   - LMS flicker, can adjust the contrast
%   - Projector spot can be turned on/off
%  Single trial
%   - 2IFC
%   - Mel or LMS directed background
%   - low or high stimulation in background
%   - LMS flicker in one interval
%   - Auditory feedback after response
%  Single acquisition
%   - Mel or LMS directed background and adaptation
%   - Low or high stimulation in background/adaptation field
%   - Length reduced compared to actual acquisition
%  In all these, the projector spot on the surround/macular blocker can be 
%  switched on/off

%% Set overall parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
if exist('radiometer','var')
    try radiometer.shutDown
    end
end
clear all; close all; clc;

approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxBRandomizedLongCableBEyePiece2_ND01';
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',simulate.oneLight); drawnow;

%% Get directions
directions = MakeNominalMeLMSens_SteadyAdapt(calibration);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Select background/adaptation
background = directions('LMS_high');
direction = directions('FlickerDirection_LMS_high');

%% flicker parameters
samplingFq = 200;
flickerFrequency = 5;
flickerDuration = .5;
flickerContrast = .05;
flickerWaveform = sinewave(flickerDuration,samplingFq,flickerFrequency);

%% Set keybindings
% A = new presentation
% B = abort
% RLT = increase contrast
% LLT = decrease contrast
% Y = toggle projector spot
keyBindings = containers.Map();
keyBindings('Q') = 'abort';
keyBindings('ESCAPE') = 'abort';
keyBindings('GP:B') = 'abort';
keyBindings('GP:LOWERLEFTTRIGGER') = 'decrease';
keyBindings('GP:LOWERRIGHTTRIGGER') = 'increase';
keyBindings('GP:A') = 'nextStim';
keyBindings('GP:Y') = 'spot';

%% Open projector spot
% Background
backgroundRGB = [0 0 0];
annulusRGB = [0 0 0];
spotRGB = [1 1 1];

spotDiameter = 130; % px
annulusDiameter = 590; % px
centerPosition = [0 0];

% We will present everything to the last display. Get its ID.
displayInfo = mglDescribeDisplays;
lastDisplay = length(displayInfo);

% Get the screen size
screenSizeInPixels = displayInfo(lastDisplay).screenSizePixel;

% Create a full-screen GLWindow object
win = GLWindow( 'SceneDimensions', screenSizeInPixels, ...
    'BackgroundColor', backgroundRGB,...
    'windowID',        lastDisplay);

% Open the window
win.open;

% Add objects
win.addRectangle(centerPosition, [screenSizeInPixels], spotRGB, 'Name', 'background');
win.addOval(centerPosition, [annulusDiameter annulusDiameter], annulusRGB, 'Name', 'annulusOuter');
win.addOval(centerPosition, [spotDiameter spotDiameter], spotRGB, 'Name', 'spot');

%% Show stimulus
while true
    responseKey = upper(WaitForKeyChar);
    if any(strcmp(responseKey,keyBindings.keys()))
        break;
    end
end
OLShowDirection(background, oneLight);

showSpot = true;
win.enableAllObjects;
win.draw;

abort = false;
while ~abort
    % Make single flicker modulation
    fprintf('Flicker contrast: %.2f%%\n',flickerContrast*100);
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, [flickerContrast, flickerContrast, flickerContrast, 0]');
    targetModulation = OLAssembleModulation([background, scaledDirection],[ones(1,length(flickerWaveform)); flickerWaveform]);
    
    % Show background, wait for keypad, show modulation, back to background.
    OLShowDirection(background, oneLight);
    fprintf('Showing stim....\n');
    OLFlicker(oneLight, targetModulation.starts, targetModulation.stops, 1/samplingFq,1);
    OLShowDirection(background, oneLight);

    %% Wait for keypad
    nextStim = false;
    while ~abort && ~nextStim
        while true
            responseKey = upper(WaitForKeyChar);
            if any(strcmp(responseKey,keyBindings.keys()))
                break;
            end
        end
        response = keyBindings(responseKey);
        if ischar(response)
            switch response
                case 'abort'
                    abort = true;
                case 'decrease'
                    flickerContrast = max(0,flickerContrast-.0025);
                    fprintf('Flicker contrast: %.2f%%\n',flickerContrast*100);
                case 'increase'
                    flickerContrast = min(5,flickerContrast+.0025);
                    fprintf('Flicker contrast: %.2f%%\n',flickerContrast*100);
                case 'spot'
                    if showSpot
                        showSpot = false;
                        win.disableAllObjects;
                    else
                        showSpot = true;
                        win.enableAllObjects;
                    end
                    win.draw;
                case 'nextStim'
                    nextStim = true;
                    break;
            end
        end
    end
end

%%
win.close;