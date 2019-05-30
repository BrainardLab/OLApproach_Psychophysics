function receptorContrasts = measurementsToReceptorContrasts(measurements, receptors)
%RECEPTORCONTRASTMEASUREMENTS Summary of this function goes here
%   Detailed explanation goes here

receptorContrasts = SPDToReceptorContrast([measurements.SPD],receptors);
end