function analysisPath = getAnalysisDir(protocol)
%GETANALYSISDIR Summary of this function goes here
%   Detailed explanation goes here
analysisPath = fullfile('analysis',['+', char(protocol)]);
end