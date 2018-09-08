function calibration = UpdateOLCalibrationWithProjectorSPD(calibration,projectorSPD)
%UPDATEOLCALIBRATIONWITHPROJECTORSPD Summary of this function goes here
%   Detailed explanation goes here
    calibration.computed.pr650MeanDark = calibration.computed.pr650MeanDark + projectorSPD;
end

