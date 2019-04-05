function LMSDirection = LMSBipolarOnBackground(bipolarContrast,background, observerAge)
%LMSBIPOLARONBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

% Extract calibration
calibration = background.calibration;

% Load params for bipolar
LMSBipolarParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSBipolarParams.primaryHeadRoom = 0;

% Set target contrast param
LMSBipolarParams.modulationContrast = bipolarContrast * [1 1 1];

% Make directions
LMSDirection = OLDirectionNominalFromParams(LMSBipolarParams, calibration, 'background', background, 'observerAge', observerAge);
end