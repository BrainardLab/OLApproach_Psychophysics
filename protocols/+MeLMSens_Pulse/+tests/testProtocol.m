function [validationsPre, corrections, validationsPost, directions] = testProtocol
%% Test MeLMSens_Pulse protocol
import('MeLMSens_Pulse.*');
approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens_Pulse';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Get calibration
calibration = getCalibration();

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~simulate.radiometer
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Get projectorSpot
% pSpot = projectorSpot(simulate.projector);

%% Update OLCalibration with pSpot
%pSpotMeasurements = projectorSpot.measure(pSpot,oneLight,radiometer);
%[calibration, pSpotSPD, pSpotLum] = projectorSpot.UpdateOLCalibrationWithProjectorSpot(calibration, pSpotMeasurements);

%% Make directions
directions = makeNominalDirections(calibration,'observerAge',32);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Test directions
% t = tests.testDirections();
% t.directions = directions;
% t.receptors = receptors;
% results = t.run();

%% Validate directions pre-correction
validationsPre = validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-4,...
                                                'nValidations',5);
                                            
%% Correct directions
corrections = correctDirections(directions,oneLight,calibration,radiometer,...
                            receptors,...
                            'primaryTolerance',1e-5,...
                            'smoothness',.001);
                        
%% Validate directions post-correction
validationsPost = validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);                                           
                                            
%% Compare validations
% TODO

%% Setup acquisitions
acquisitions = makeAcquisitions(directions, receptors,...
                'NTrialsPerStaircase',1);

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];

if ~simulate.gamepad
    gamePad = GamePad();
    trialKeyBindings('GP:B') = 'abort';
    trialKeyBindings('GP:UPPERLEFTTRIGGER') = [1 0];
    trialKeyBindings('GP:UPPERRIGHTTRIGGER') = [0 1];    
    trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
    trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
else
    gamePad = [];
end
trialResponseSys = responseSystem(trialKeyBindings,gamePad);

%% Adjust projectorSpot
% projectorSpot.adjust(pSpot,gamePad);

%% Run
% pSpot.show();
for acquisition = acquisitions
    fprintf('Running acquisition %s...\n',acquisition.name)
    acquisition.initializeStaircases();
    acquisition.runAcquisition(oneLight, trialResponseSys);
    fprintf('Acquisition complete.\n'); Speak('Acquisition complete.',[],230);
end

%% Close connections
fprintf('Closing devices...');
oneLight.close();
radiometer.shutDown;
pSpot.close();
gamePad.shutDown();
fprintf('done.\n');
end