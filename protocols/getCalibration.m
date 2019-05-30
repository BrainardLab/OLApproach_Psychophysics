function calibration = getCalibration()
% Get calibration for the protocol
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxB';
calibrationType = 'BoxB_BulbJ_LiquidLightGuideC_EyePiece3_DLP_[05 05 05]_ND21_ND00';
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');
end