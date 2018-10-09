function [projSPD, projLum, SPDs] = getProjectorSPD(pSpot,oneLight, radiometer)
%GETPROJECTORSPD Summary of this function goes here
%   Detailed explanation goes here
    SPDs = measureProjectorSpot(pSpot,oneLight, radiometer);
    [projSPD, projLum] = analyzeProjectorSpot(SPDs);
end