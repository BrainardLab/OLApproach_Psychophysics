%% Demo MeLMSens_SteadyAdapt protocol
%
% Stimuli to demonstrate:
%  Single modulation
%   - Mel or LMS directed background
%   - Low or high stimulation in background
%   - LMS flicker, can adjust the contrast
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
calibrationType = 'BoxBRandomizedLongCableBEyePiece3Beamsplitter';
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

%% Set demo response system
% A = new presentation
% B = abort ('q', 'escape' on keyboard also work)
% RLT = increase contrast
% LLT = decrease contrast
% Y = toggle projector spot
demoKeyBindings = containers.Map();
demoKeyBindings('ESCAPE') = 'abort';
demoKeyBindings('GP:B') = 'abort';
demoKeyBindings('Q') = 'decrease';
demoKeyBindings('P') = 'increase';
demoKeyBindings('GP:LOWERLEFTTRIGGER') = 'decrease';
demoKeyBindings('GP:LOWERRIGHTTRIGGER') = 'increase';
demoKeyBindings('GP:A') = 'nextStim';
demoKeyBindings('ENTER') = 'nextStim';
demoKeyBindings('LEFTENTER') = 'nextStim';
demoKeyBindings('Y') = 'toggelSpot';
demoKeyBindings('GP:Y') = 'toggleSpot';
demoResponseSys = responseSystem(demoKeyBindings);

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];
trialResponseSys = responseSystem(trialKeyBindings);

%% Show stimulus
% Show background, wait for initial key press
projectorWindow = makeProjectorSpot('Fullscreen',~simulate.projector); % make projector spot window object
toggleProjectorSpot(projectorWindow,true); % toggle on

abort = false;
commandwindow;
while ~abort
    OLShowDirection(background, oneLight);

    % Make single trial
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, [flickerContrast, flickerContrast, flickerContrast, 0]');
    targetModulation = OLAssembleModulation([background, scaledDirection],[ones(1,length(flickerWaveform)); flickerWaveform]);
    referenceModulation = OLAssembleModulation(background, ones([1,length(flickerWaveform)]));    
    trial = Trial_NIFC(2,targetModulation,referenceModulation);
    
    % Show background, show trial, back to background.
    OLShowDirection(background, oneLight);
    fprintf('Showing trial with contrast: %.2f%%...\n',flickerContrast*100);
    [abort, trial] = trial.run(oneLight,samplingFq,trialResponseSys);
    if ~abort && trial.correct
        Beeper(300); Beeper;
    else
        Beeper(300); WaitSecs(.15); Beeper(300);
    end
    OLShowDirection(background, oneLight);

    % Process input
    nextStim = false;
    while ~abort && ~nextStim
        WaitSecs(.05);
        response = demoResponseSys.waitForResponse;
        response = response{1};
        if ischar(response)
            switch response
                case 'abort'
                    abort = true;
                    break;
                case 'decrease'
                    flickerContrast = max(0,flickerContrast-.0025);
                    fprintf('Flicker contrast: %.2f%%\n',flickerContrast*100);
                case 'increase'
                    flickerContrast = min(5,flickerContrast+.0025);
                    fprintf('Flicker contrast: %.2f%%\n',flickerContrast*100);
                case 'toggleSpot'
                    toggleProjectorSpot(projectorWindow);
                case 'nextStim'
                    nextStim = true;
                    break;
            end
        end
    end
end
projectorWindow.close;