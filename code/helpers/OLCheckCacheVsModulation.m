function OLCheckCacheVsModulation(cacheFile, modulationFile);
%% Load the validation file
%valFile = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-SDirected/ShortCableAEyePiece1/11-Mar-2014_09_12_14/validation/12-Mar-2014_17_38_25/Cache-SDirected-ShortCableAEyePiece1-SpotCheck.mat';
%load(valFile);

%valPrimariesMax = cals{end}.modulationMaxMeas.primaries;
%valPrimariesMin = cals{end}.modulationMinMeas.primaries;
%valPrimariesBG = cals{end}.modulationBGMeas.primaries;


%% Load the cacheFile
observerAge = 44;
%cacheFile = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-SDirected.mat';
load(cacheFile);
cachePrimariesMax = ShortCableAEyePiece1{1}.data(observerAge).backgroundPrimary + 1*(ShortCableAEyePiece1{1}.data(observerAge).modulationPrimarySignedPositive - ShortCableAEyePiece1{1}.data(observerAge).backgroundPrimary);
cachePrimariesMin = ShortCableAEyePiece1{1}.data(observerAge).backgroundPrimary + -1*(ShortCableAEyePiece1{1}.data(observerAge).modulationPrimarySignedPositive - ShortCableAEyePiece1{1}.data(observerAge).backgroundPrimary);
cachePrimariesBG = ShortCableAEyePiece1{1}.data(observerAge).backgroundPrimary + 0*(ShortCableAEyePiece1{1}.data(observerAge).modulationPrimarySignedPositive - ShortCableAEyePiece1{1}.data(observerAge).backgroundPrimary);

%% Load in the modulation file
%modulationFile = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/modulations/Modulation-SDirected-45sFrequencyModulation-44.mat';
load(modulationFile);

% Find the max. index
tmp = find(modulation(1).powerLevels == 1);
maxIndex = tmp(1);

tmp = find(modulation(1).powerLevels == -1);
minIndex = tmp(1);

tmp = find(modulation(1).powerLevels == 0);
BGIndex = tmp(1);

modPrimariesMax = modulation(1).primaries(maxIndex, :);
modPrimariesMin = modulation(1).primaries(minIndex, :);
modPrimariesBG = modulation(1).primaries(BGIndex, :);

figure;
subplot(1, 3, 1);
plot(cachePrimariesMax, modPrimariesMax);
subplot(1, 3, 2);
plot(cachePrimariesMin, modPrimariesMin);
subplot(1, 3, 3);
plot(cachePrimariesBG, modPrimariesBG);

corr(cachePrimariesMax, modPrimariesMax')
corr(cachePrimariesMin, modPrimariesMin')
corr(cachePrimariesBG, modPrimariesBG')

all(cachePrimariesMax == modPrimariesMax')
all(cachePrimariesMin == modPrimariesMin')
all(cachePrimariesBG == modPrimariesBG')