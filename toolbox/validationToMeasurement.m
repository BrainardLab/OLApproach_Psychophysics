function measurement = validationToMeasurement(validation)
%VALIDATIONTOMEASUREMENT Summary of this function goes here
%   Detailed explanation goes here
measurement = struct();
measurement.SPD = validation.SPDcombined.measuredSPD;
measurement.wavelengths = [];
measurement.measurable.primaryValues = validation.measuredPrimaryValues(:,2);
measurement.measurable.temperatures = validation.temperatures;
measurement.measurable.state = validation.stateTrackingData;
measurement.time = validation.time(2);
measurement.measurable.label = validation.label;
measurement.radiometerInfo = struct();
end

