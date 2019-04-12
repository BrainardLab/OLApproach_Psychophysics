function measurement = measureRGB(windowObject, RGB, radiometer)
%MEASURESINGLELEVEL Summary of this function goes here
%   Detailed explanation goes here

windowObject.Visible = true;
windowObject.RGB = RGB;
SPD = radiometer.measure();

measurement.SPD = SPD;
measurement.wavelengths = MakeItWls(radiometer.userS);

radiometerInfo = radiometer.currentConfiguration;
radiometerInfo.model = radiometer.deviceModelName;
radiometerInfo.serial = radiometer.deviceSerialNum;

measurement.radiometerInfo = radiometerInfo;
end