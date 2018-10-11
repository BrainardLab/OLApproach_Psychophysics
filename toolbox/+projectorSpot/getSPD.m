function [averageSPD, averageLum, measurements] = getSPD(pSpot,oneLight, radiometer)
%GETPROJECTORSPD Summary of this function goes here
%   Detailed explanation goes here
    measurements = projectorSpot.measure(pSpot,oneLight, radiometer);
    [averageSPD, averageLum] = projectorSpot.analyze(measurements);
end