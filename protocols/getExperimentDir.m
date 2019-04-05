function experimentPath = getExperimentDir(protocol)
%GETEXPERIMENTDIR Summary of this function goes here
%   Detailed explanation goes here
experimentPath = fullfile('protocols',['+', char(protocol)]);
end