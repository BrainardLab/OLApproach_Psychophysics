%%%%%%% OFF TO ON
%% Code to turn all mirrors off and on
ol = OneLight;

%% Off 
OLAllMirrorsOff;

%% On
OLAllMirrorsOn;

%%
%%%%%%% BG TO STEP
cal = OLGetCalibrationStructure;
load('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-LightFlux.mat')
[bgStarts, bgStops] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, BoxARandomizedLongCableBEyePiece1_ND06{1}.data(30).backgroundPrimary));
[modStarts, modStops] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, BoxARandomizedLongCableBEyePiece1_ND06{1}.data(30).modulationPrimarySignedPositive));

%%
ol = OneLight;
ol.setMirrors(bgStarts, bgStops);

%%
ol = OneLight;
ol.setMirrors(modStarts, modStops);