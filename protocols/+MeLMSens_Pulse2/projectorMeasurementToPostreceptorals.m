function [LMS,LminusM] = projectorMeasurementToPostreceptorals(measurements, receptors)
%PROJECTORMEASUREMENTTOPOSTRECEPTORALS Summary of this function goes here
%   Detailed explanation goes here

avgMeasurements = [];
for measurement = measurements
    avgMeasurements = [avgMeasurements averageMeasurements(measurement)];
end

receptorContrasts = measurementsToReceptorContrasts(avgMeasurements,receptors);

% Select only the contrasts with the background
backgroundIdx = ceil(length(receptorContrasts)/2);
receptorContrasts = receptorContrasts(backgroundIdx,:,:);
receptorContrasts = reshape(permute(receptorContrasts,[3 1 2]),4,[]);

% LMS contrast
LMS = sum(receptorContrasts(1:3,:),1)/3;
LminusM = receptorContrasts(1,:)-receptorContrasts(2,:);
end