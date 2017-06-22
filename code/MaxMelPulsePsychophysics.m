% MaxMelPulsePsychophysics
%
% Description:
%   Define the parameters for the MaxPulsePsychophysics protocol of the
%   OLApproach_Psychophysics approach, and then invoke each of the
%   functions required to set up and run the experiment.

%% Clear
clear; close all;

%% Set the parameter structure here
params.approach = 'OLApproach_Psychophysics';
params.protocol = 'MaxMelPulsePsychophysics';
params.experiment = 'MaxMelPulsePsychophysics';
params.experimentSuffix = 'MaxMelPulsePsychophysics';
params.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND02';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;                 % Assuming dilated pupil
params.isActive = 1;
params.useAmbient = 1;
params.OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;              

%% Make the nominal modulation primaries
Psychophysics.MakeDirectionNominalPrimaries(params);

%% Make the corrected modulation primaries
%Psychophysics.MakeDirectionCorrectedPrimaries(params);

%% Make the Starts and Stops
Psychophysics.MakeModulationStartsStops(params)
