function [validationsPre, validationsPost, directions] = testMeLMSens_SteadyAdapt
%% Test MeLMSens_SteadyAdapt protocol
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

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~simulate.radiometer
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Get directions
directions = MakeNominalMeLMSens_SteadyAdapt(calibration,'observerAge',32);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Validate directions pre-correction
validationsPre = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,'receptors',receptors);

%% Correct directions
correctMeLMSens_SteadyAdapt(directions,oneLight,calibration,radiometer,'receptors',receptors);

%% Validate directions post-correction
validationsPost = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,'receptors',receptors);

%% Compare validations

end