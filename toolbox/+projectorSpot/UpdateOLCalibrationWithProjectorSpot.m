function [calibration, projSPD, projLum] = UpdateOLCalibrationWithProjectorSpot(calibration,measurements)
%UPDATECALIBRATIONWITHPROJECTORSPD Summary of this function goes here
%   Detailed explanation goes here
    [projSPD, projLum] = projectorSpot.analyze(measurements);
    calibration = OLCalibrationAddSPDToDarkLight(calibration,projSPD);
end