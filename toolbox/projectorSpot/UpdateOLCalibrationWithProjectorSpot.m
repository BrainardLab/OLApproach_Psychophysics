function [calibration, projSPD, projLum, SPDs] = UpdateOLCalibrationWithProjectorSpot(calibration,pSpot,oneLight, radiometer)
%UPDATECALIBRATIONWITHPROJECTORSPD Summary of this function goes here
%   Detailed explanation goes here
    [projSPD, projLum, SPDs] = getProjectorSPD(pSpot,oneLight, radiometer);
    calibration = UpdateOLCalibrationWithProjectorSPD(calibration,projSPD);
end