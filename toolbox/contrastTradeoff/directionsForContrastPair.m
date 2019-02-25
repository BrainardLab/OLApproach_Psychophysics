function [Mel_low, Mel_step, LMS_low, LMS_high] = directionsForContrastPair(melContrast,LMSContrast, calibration, observerAge)
%DIRECTIONSFORCONTRASTPAIR Summary of this function goes here
%   Detailed explanation goes here

[Mel_low, Mel_step, Mel_high] = MelUnipolarAtContrast(melContrast,calibration,observerAge);

LMS_low = LMSBipolarOnBackground(LMSContrast,Mel_low,observerAge);
LMS_high = LMSBipolarOnBackground(LMSContrast,Mel_high,observerAge);

end