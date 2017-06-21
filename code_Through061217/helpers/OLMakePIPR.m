function [cacheData, olCache, params] = OLMakePIPR(params)
% [cacheData, olCache, params] = OLMakePIPR(params)
%
% Shows a monochromatic nm light.

% Setup the directories we'll use.  We count on the
% standard relative directory structure that we always
% use in our (BrainardLab) experiments.
baseDir = fileparts(fileparts(which('OLMakePIPR')));
configDir = fullfile(baseDir, 'config', 'stimuli');
cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');

if ~isdir(cacheDir)
    mkdir(cacheDir);
end

%% Load the calibration file.
cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName, [], getpref('OneLight', 'OneLightCalData'));
assert(~isempty(cal), 'OLFlickerComputeModulationSpectra:NoCalFile', 'Could not load calibration file: %s', ...
    OLCalibrationTypes.(params.calibrationType).CalFileName);
calID = OLGetCalID(cal);

%% Pull out S
S = cal.describe.S;

% Get the B_primary
B_primary = cal.computed.pr650M;

%% Create the cache object.
olCache = OLCache(cacheDir, cal);

% Create the cache file name.
[~, cacheFileName] = fileparts(params.cacheFile);

% Generate the monochromatic spd
lambda = 0.001;
spd1 = OLMakeMonochromaticSpd(cal, params.peakWavelengthNm, params.fwhmNm);
[maxSpd1, scaleFactor1] = OLFindMaxSpectrum(cal, spd1, lambda);

% Find the primaries for that
primary0 = OLSpdToPrimary(cal, maxSpd1, 'lambda', lambda);
backgroundPrimary = zeros(size(primary0));

for observerAgeInYears = 20:60
    %% Get the pre-receptoral filters
    lensTransmit = LensTransmittance(S, 'Human', 'CIE', observerAgeInYears, params.pupilDiameterMm);
    macTransmit = MacularTransmittance(S, 'Human', 'CIE', params.fieldSizeDegrees);
    
    %% Calculate the intensity
    radianceWattsPerM2Sr = (B_primary * primary0) .* lensTransmit' .* macTransmit';
    pupilAreaMm2 = pi*((params.pupilDiameterMm/2)^2);
    eyeLengthMm = 17;
    irradianceWattsPerUm2 = RadianceToRetIrradiance(radianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
    irradianceQuantaPerUm2Sec = EnergyToQuanta(S,irradianceWattsPerUm2);
    irradianceQuantaPerCm2Sec = (10.^8)*irradianceQuantaPerUm2Sec;
    irradianceQuantaPerCm2SecMax = irradianceQuantaPerCm2Sec;
    
    % Find the scalar that gets us the target intensity
    scalar = 10^params.filteredRetinalIrradianceLogPhotons / sum(irradianceQuantaPerCm2Sec);
    
    % Cap at 1
    if scalar > 1
        scalar = 1;
    end
    
    primary1 = scalar*primary0;
    
    %% Calculate the intensity
    radianceWattsPerM2Sr = (B_primary * primary1) .* lensTransmit' .* macTransmit';
    irradianceWattsPerUm2 = RadianceToRetIrradiance(radianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
    irradianceQuantaPerUm2Sec = EnergyToQuanta(S,irradianceWattsPerUm2);
    irradianceQuantaPerCm2Sec = (10.^8)*irradianceQuantaPerUm2Sec;
    
    %% Display the intensity information
    fprintf('\n> Observer age: %g\n',observerAgeInYears);
    fprintf('  - Intensity: \t<strong>%.2f</strong> [max.] [log quanta/cm2/sec]\n', log10(sum(irradianceQuantaPerCm2SecMax)));
    fprintf('  \t\t<strong>%.2f</strong> [pegged] [log quanta/cm2/sec]\n', log10(sum(irradianceQuantaPerCm2Sec)));
    fprintf('  - Scalar: \t<strong>%.2f</strong>\n', scalar);
    
    %% Save out important information
    cacheData.data(observerAgeInYears).describe.params = params; % Parameters
    cacheData.cal = cal;
    
    %% Stick in there the stuff we've calculated
    % Background
    cacheData.data(observerAgeInYears).backgroundPrimary = backgroundPrimary;
    cacheData.data(observerAgeInYears).backgroundSpd = (B_primary*backgroundPrimary) + cal.computed.pr650MeanDark;
    
    % Modulation (unsigned)
    cacheData.data(observerAgeInYears).differencePrimary = primary1;
    cacheData.data(observerAgeInYears).differenceSpd = B_primary*primary1;
    
    % Modulation (signed)
    cacheData.data(observerAgeInYears).modulationPrimarySignedPositive = primary1;
    cacheData.data(observerAgeInYears).modulationPrimarySignedNegative = NaN;
    cacheData.data(observerAgeInYears).modulationSpdSignedPositive = (B_primary*primary1) + cal.computed.pr650MeanDark;
    cacheData.data(observerAgeInYears).modulationSpdSignedNegative = NaN;
    
    cacheData.data(observerAgeInYears).ambientSpd = cal.computed.pr650MeanDark;
    cacheData.data(observerAgeInYears).operatingPoint = backgroundPrimary;
    
    photoreceptorClasses = allwords(params.photoreceptorClasses, ',');
    cacheData.data(observerAgeInYears).describe.photoreceptors = photoreceptorClasses;     % Photoreceptors
    cacheData.data(observerAgeInYears).describe.S = S;     % Photoreceptors
    T_receptors = GetHumanPhotoreceptorSS(S, photoreceptorClasses, params.fieldSizeDegrees, observerAgeInYears, params.pupilDiameterMm, [], []);
    cacheData.data(observerAgeInYears).describe.T_receptors = T_receptors;
    
    % Include the compute method
    cacheData.data(observerAgeInYears).computeMethod = OLComputeMethods.ReceptorIsolate;
    cacheData.computeMethod = char(OLComputeMethods.ReceptorIsolate);
end