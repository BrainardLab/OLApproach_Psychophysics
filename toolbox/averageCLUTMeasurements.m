function averageCLUT = averageCLUTMeasurements(CLUT)
%AVERAGECLUTMEASUREMENTS Summary of this function goes here
%   Detailed explanation goes here

averageCLUT = struct([]);
for entry = CLUT
    averageMeasurement = averageMeasurements(entry);
    averageCLUT = [averageCLUT averageMeasurement];
end

end