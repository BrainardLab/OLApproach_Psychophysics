function averageMeasurement = averageMeasurements(measurements)
%AVERAGEMEASUREMENT Summary of this function goes here
%   Detailed explanation goes here

%% Check input
assert(isequal(measurements.wavelengths),'Inconsistent wavelength sampling across measurements');
assert(isequal(measurements.radiometerInfo),'Inconsistent radiometer information/configuration');

%% Initialize output
averageMeasurement = struct();
averageMeasurement.measurable = measurements(1).measurable;
averageMeasurement.radiometerInfo = measurements(1).radiometerInfo;
averageMeasurement.wavelengths = measurements(1).wavelengths;
averageMeasurement.time = [measurements.time];

%% Average SPD
SPDs = [measurements.SPD]; % assume SPD are column vectors, cat horz
medianSPD = median(SPDs,2); % median over columns
SDSPD = std(SPDs,0,2); % std (unweighted) over columns

averageMeasurement.SPD = medianSPD;
averageMeasurement.SDSPD = SDSPD;
end