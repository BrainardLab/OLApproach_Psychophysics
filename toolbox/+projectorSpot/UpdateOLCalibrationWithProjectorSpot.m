function [calibration, projSPD, projLum, SPDs] = UpdateOLCalibrationWithProjectorSpot(calibration,pSpot,oneLight, radiometer)
%UPDATECALIBRATIONWITHPROJECTORSPD Summary of this function goes here
%   Detailed explanation goes here
    [projSPD, projLum, SPDs] = projectorSpot.getSPD(pSpot,oneLight, radiometer);
    calibration = projectorSpot.UpdateOLCalibrationWithProjectorSPD(calibration,projSPD);
end 