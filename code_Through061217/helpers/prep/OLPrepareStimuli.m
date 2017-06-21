%OLPrepareStimuli.m

theCalTypes = {'OLEyeTrackerLongCableEyePiece1', 'OLEyeTrackerShortCableEyePiece1'};
theModulationDirections = {'Background', 'Isochromatic', 'LMDirected', 'MelanopsinDirected', 'SDirected', 'LMinusMDirected'};

for c = 2
    for m = 3:5
        try
            OLFindIsolatingPrimarySettings(['Cache-' theModulationDirections{m} '-' theCalTypes{c} '.cfg']);
        end
    end
end
%%
% For 'RSRD'
OLFindIsolatingPrimarySettings('Cache-RodDirected-OLEyeTrackerLongCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-RodDirected-OLEyeTrackerShortCableEyePiece1.cfg');

OLFlickerCalculateSplatter('Cache-Background.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-Isochromatic.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-LMDirected.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-LMinusMDirected.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-MelanopsinDirected.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-SDirected.mat', 'EyeTrackerLongCableEyePiece1');
%OLFlickerCalculateSplatter('Cache-MelanopsinDirectedRobust.mat', 'EyeTrackerLongCableEyePiece1');

OLFlickerCalculateSplatter('Cache-Background.mat', 'EyeTrackerShortCableEyePiece1');
OLFlickerCalculateSplatter('Cache-LMDirected.mat', 'EyeTrackerShortCableEyePiece1');
OLFlickerCalculateSplatter('Cache-MelanopsinDirected.mat', 'EyeTrackerShortCableEyePiece1');
OLFlickerCalculateSplatter('Cache-SDirected.mat', 'EyeTrackerShortCableEyePiece1');

OLFlickerValidateCacheFile('Cache-Isochromatic.mat');
% OLFlickerValidateCacheFile('Cache-LMDirected.mat');
% OLFlickerValidateCacheFile('Cache-MelanopsinDirected.mat');
% OLFlickerValidateCacheFile('Cache-SDirected.mat');
% OLFlickerValidateCacheFile('Cache-LMinusMDirected.mat');
%
OLFlickerAnalyzeValidation('Cache-Isochromatic.mat');
OLFlickerAnalyzeValidation('Cache-LMDirected.mat');
OLFlickerAnalyzeValidation('Cache-MelanopsinDirected.mat');
OLFlickerAnalyzeValidation('Cache-MelanopsinDirectedRobust.mat');
OLFlickerAnalyzeValidation('Cache-SDirected.mat');
OLFlickerAnalyzeValidation('Cache-LMinusMDirected.mat');

OLFindIsolatingPrimarySettings('Cache-Background-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-Isochromatic-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-LMDirected-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-MelanopsinDirected-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-SDirected-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-LMinusMDirected-OLEyeTrackerShortCableEyePiece1.cfg');

OLFlickerValidateCacheFile('Cache-Isochromatic.mat');
OLFlickerValidateCacheFile('Cache-LMDirected.mat');
OLFlickerValidateCacheFile('Cache-MelanopsinDirected.mat');
OLFlickerValidateCacheFile('Cache-MelanopsinDirectedRobust.mat');
OLFlickerValidateCacheFile('Cache-SDirected.mat');
OLFlickerValidateCacheFile('Cache-LMinusMDirected.mat');

% Test a robust mel
OLFindIsolatingPrimarySettings('Cache-MelanopsinDirectedRobust-OLEyeTrackerShortCableEyePiece1.cfg');
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedRobust-50sContrastModulation.cfg', 26);

%% Contrast modulation, 50 s
theObserverAges = [25 26];
for observerAgeInYears = theObserverAges
    OLReceptorIsolateMakeModulationStartsStops('Modulation-Isochromatic-50sContrastModulation.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirected-50sContrastModulation.cfg', observerAgeInYears);
    %OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-50sContrastModulation.cfg', observerAgeInYears);
    %OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-50sContrastModulation.cfg', observerAgeInYears);
    %OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300sContrastModulation.cfg', observerAgeInYears);
end


%% Flicker modulation, 12 s
theObserverAges = [25 26 28 43];
for observerAgeInYears = theObserverAges
    OLReceptorIsolateMakeModulationStartsStops('Modulation-Isochromatic-12sFlicker.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirected-12sFlicker.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-12sFlicker.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirectedRobust-12sFlicker.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-12sFlicker.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-LMinusMDirected-12sFlicker.cfg', observerAgeInYears);
end


%% Demo
%% Contrast modulation, 50 s
theObserverAges = [32];
for observerAgeInYears = theObserverAges
    OLReceptorIsolateMakeModulationStartsStops('Modulation-LMDirected-50sContrastModulation.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-50sContrastModulation.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-50sContrastModulation.cfg', observerAgeInYears);
end


%% Distortion product controls, contrast modulation, 50 s
% Rod control
% Contrast modulation
OLFindIsolatingPrimarySettings('Cache-Background-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-RodDirected-OLEyeTrackerShortCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-Background-OLEyeTrackerLongCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-RodDirected-OLEyeTrackerLongCableEyePiece1.cfg');
OLFindIsolatingPrimarySettings('Cache-MelanopsinDirected-OLEyeTrackerShortCableEyePiece1.cfg');

OLFlickerCalculateSplatter('Cache-Background.mat', 'EyeTrackerShortCableEyePiece1');
OLFlickerCalculateSplatter('Cache-Background.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-RodDirected.mat', 'EyeTrackerShortCableEyePiece1');
OLFlickerCalculateSplatter('Cache-RodDirected.mat', 'EyeTrackerLongCableEyePiece1');
OLFlickerCalculateSplatter('Cache-MelanopsinDirected.mat', 'EyeTrackerShortCableEyePiece1');

OLFlickerValidateCacheFile('Cache-MelanopsinDirected.mat');
OLFlickerValidateCacheFile('Cache-RodDirected.mat');

OLFlickerAnalyzeValidation('Cache-MelanopsinDirected.mat');

theObserverAges = [26];
for observerAgeInYears = theObserverAges
    OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300sContrastModulation.cfg', observerAgeInYears);
    OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-50sScaledContrastModulation.cfg', observerAgeInYears);
    
    
    %OLReceptorIsolateMakeModulationStartsStops('Modulation-RodDirectedHigh-50sContrastModulation.cfg', observerAgeInYears);
    %OLReceptorIsolateMakeModulationStartsStops('Modulation-RodDirectedLow-50sContrastModulation.cfg', observerAgeInYears);
    
end


%% HOW TO DO VALIDATION
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
OLValidateCacheFile(fullfile(cacheDir, 'Cache-SDirected.mat'), 'mspits@sas.upenn.edu', 'PR-670', ...
    1, 1, 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', 'EyeTrackerShortCableEyePiece1', 'CALCULATE_SPLATTER', true);
OLValidateCacheFile(fullfile(cacheDir, 'Cache-LMDirected.mat'), 'mspits@sas.upenn.edu', 'PR-670', ...
    0, 0, 'FullOnMeas', false, 'ReducedPowerLevels', true,  'selectedCalType', 'EyeTrackerShortCableEyePiece1', 'CALCULATE_SPLATTER', true);
OLValidateCacheFile(fullfile(cacheDir, 'Cache-MelanopsinDirected.mat'), 'mspits@sas.upenn.edu', 'PR-670', ...
    0, 1, 'FullOnMeas', false, 'ReducedPowerLevels', true,  'selectedCalType', 'EyeTrackerShortCableEyePiece1', 'CALCULATE_SPLATTER', true);
%%
valDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-OmniSilent/EyeTrackerShortCableEyePiece1/31-Jan-2014_19_13_36/validation/04-Feb-2014_17_52_34';
valFileName = 'Cache-OmniSilent-EyeTrackerShortCableEyePiece1-SpotCheck.mat';
OLAnalyzeValidationReceptorIsolate(fullfile(valDir, valFileName));

%%
theDirections = {'SDirected', 'OmniSilent', 'MelanopsinDirected', 'LMDirected', 'LMinusMDirected', 'RodDirected', 'Isochromatic', 'KleinSilent'};
theOnVector = [1 0 0 0 0 0 0 0];
theOffVector = [0 0 0 0 0 0 0 1];
for d = 8
    OLFindIsolatingPrimarySettings(['Cache-' theDirections{d} '-OLEyeTrackerShortCableEyePiece1.cfg']);
    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
    OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', 'EyeTrackerShortCableEyePiece1', 'CALCULATE_SPLATTER', true);
end

%%%

%% Validate
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
theDirections = {'LMDirected', 'LMinusMDirected', 'SDirected', 'MelanopsinDirected', 'RodDirected', 'MelanopsinDirectedRobust', 'OmniSilent', 'Isochromatic', 'KleinSilent'};
theOnVector = [1 0 0 0 0 0 0 0 0];
theOffVector = [0 0 0 0 0 0 0 0 1];
WaitSecs(20);
for d = 1:length(theDirections)
    OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', 'ShortCableAEyePiece1', 'CALCULATE_SPLATTER', true);
end

%% Re run validation analyses
%theFiles = {'Cache-OmniSilent/LongCableAEyePiece1/07-Feb-2014_13_39_23/validation/07-Feb-2014_18_18_45' ; 'Cache-OmniSilent/LongCableAEyePiece1/07-Feb-2014_13_39_23/validation/07-Feb-2014_19_15_07' ; 'Cache-RodDirected/EyeTrackerShortCableEyePiece1/31-Jan-2014_19_13_36/validation/04-Feb-2014_18_04_41' ; 'Cache-RodDirected/EyeTrackerShortCableEyePiece1/31-Jan-2014_19_13_36/validation/05-Feb-2014_15_12_59' ; 'Cache-RodDirected/LongCableAEyePiece1/07-Feb-2014_13_39_23/validation/07-Feb-2014_18_02_54' ; 'Cache-SDirected/EyeTrackerShortCableEyePiece1/31-Jan-2014_19_13_36/validation/03-Feb-2014_18_46_35' ; 'Cache-SDirected/EyeTrackerShortCableEyePiece1/31-Jan-2014_19_13_36/validation/04-Feb-2014_17_47_49' ; 'Cache-SDirected/EyeTrackerShortCableEyePiece1/31-Jan-2014_19_13_36/validation/05-Feb-2014_14_52_42' ; 'Cache-SDirected/LongCableAEyePiece1/06-Feb-2014_18_06_09/validation/07-Feb-2014_11_38_47' ; 'Cache-SDirected/LongCableAEyePiece1/07-Feb-2014_13_39_23/validation/07-Feb-2014_17_57_36' };

theFiles = {'Cache-Isochromatic/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_32_19' ; ...
    'Cache-LMDirected/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_35_26' ; ...
    'Cache-LMinusMDirected/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_38_14/' ; ...
    'Cache-MelanopsinDirected/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_21_01' ; ...
    'Cache-MelanopsinDirectedRobust/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_42_32' ; ...
    'Cache-OmniSilent/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_51_31' ; ...
    'Cache-RodDirected/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_50_05' ; ...
    'Cache-SDirected/LongCableAEyePiece1/25-Feb-2014_16_43_41/validation/26-Feb-2014_11_29_21'}

stimDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/';
for f = 1:length(theFiles)
    theFileToAnalyze = ls([fullfile(stimDir, theFiles{f}) '/Cache*.mat']);
    OLAnalyzeValidationReceptorIsolate(theFileToAnalyze);
    close all;
end;
%%
%%% TTF4Dc protocol

observerAge = 44;

OLReceptorIsolateMakeModulationStartsStops('Modulation-SDirected-45sFrequencyModulation.cfg', observerAge);
OLReceptorIsolateMakeModulationStartsStops('Modulation-RodDirected-45sFrequencyModulation.cfg', observerAge);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinDirected-45sFrequencyModulation.cfg', observerAge);
OLReceptorIsolateMakeModulationStartsStops('Modulation-OmniSilent-45sFrequencyModulation.cfg', observerAge);
OLReceptorIsolateMakeModulationStartsStops('Modulation-Background-300s.cfg', observerAge);
