function testMeLMSens_SteadyAdapt
%% Test MeLMSens_SteadyAdapt protocol
approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens';

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxBRandomizedLongCableBEyePiece3Beamsplitter';
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',true); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
radiometer = [];

%% Get directions
directions = MakeNominalMeLMSens_SteadyAdapt(calibration,'observerAge',32);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Validate directions pre-correction
validations = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,'receptors',receptors);

%% Correct directions
CorrectMeLMSens_SteadyAdapt(directions,oneLight,calibration,radiometer,'receptors',receptors);

%% Validate directions post-correction
validations = validateMeLMSens_SteadyAdapt(directions,oneLight,radiometer,'receptors',receptors);

%% Compare validations


end