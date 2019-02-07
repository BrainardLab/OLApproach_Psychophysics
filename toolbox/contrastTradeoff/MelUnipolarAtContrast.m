function [Mel_low, Mel_Step, Mel_high] = MelUnipolarAtContrast(unipolarContrast, calibration, observerAge)
%MELDIRECTIONATCONTRAST Summary of this function goes here
%   Detailed explanation goes here

%% Load params
MelUnipolarParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
MelUnipolarParams.primaryHeadRoom = 0;

%% Set target contrast param
MelUnipolarParams.modulationContrast = OLUnipolarToBipolarContrast(unipolarContrast);

%% Make directions
[Mel_Step, Mel_low] = OLDirectionNominalFromParams(MelUnipolarParams, calibration, 'observerAge', observerAge);
Mel_high = Mel_low + Mel_Step;
end