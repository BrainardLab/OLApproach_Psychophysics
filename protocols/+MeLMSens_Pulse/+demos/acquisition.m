%% Demo MeLMSens_SteadyAdapt protocol
%
% Stimuli to demonstrate:
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
% % A = new presentation
% % B = abort ('q', 'escape' on keyboard also work)
% % RLT = increase contrast
% % LLT = decrease contrast
% % Y = toggle projector spot
% demoKeyBindings = containers.Map();
% demoKeyBindings('ESCAPE') = 'abort';
% demoKeyBindings('GP:B') = 'abort';
% demoKeyBindings('Y') = 'toggleSpot';
% demoKeyBindings('GP:Y') = 'toggleSpot';
% demoResponseSys = responseSystem(demoKeyBindings);

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];
trialResponseSys = responseSystem(trialKeyBindings);

%% Make acquisition
acquisition = Acquisition_FlickerSensitivity_2IFC(...
    background,...
    direction,...
    receptors,...
    'name',"DEMO");
acquisition.NTrialsPerStaircase = 10;

%% Show stimulus
projectorWindow = makeProjectorSpot('Fullscreen',~simulate.projector); % make projector spot window object
toggleProjectorSpot(projectorWindow,true); % toggle on

abort = false;
commandwindow;

fprintf('Running acquisition %s...\n',acquisition.name)
acquisition.initializeStaircases();
acquisition.runAcquisition(oneLight, trialResponseSys);
fprintf('Acquisition complete.\n'); Speak('Acquisition complete.',[],230);

projectorWindow.close;