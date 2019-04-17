function measurements = measureRGB(windowObject, RGB, radiometer, NMeasurements)
%MEASURESINGLELEVEL Summary of this function goes here
%   Detailed explanation goes here

windowObject.Visible = true;
windowObject.RGB = RGB;

radiometerInfo = radiometer.currentConfiguration;
radiometerInfo.model = radiometer.deviceModelName;
radiometerInfo.serial = radiometer.deviceSerialNum;

measurements = struct([]);
for i = 1:NMeasurements
    fprintf('Measuring %d/%d...',i,NMeasurements);
    % Initialize measurement output
    measurement = struct();
    
    % Store measurement
    SPD = radiometer.measure();
    measurement.SPD = reshape(SPD,[length(SPD),1]);
    measurement.wavelengths = MakeItWls(radiometer.userS);

    % Timestamp
    measurement.time = datetime();    
    
    % Store metadata about what's being measured
    measurement.measurable = struct(windowObject);    

    % Add radiometer metadata
    measurement.radiometerInfo = radiometerInfo;
    
    % Append
    measurements = [measurements; measurement];
    
    fprintf('done.\n');
end
end