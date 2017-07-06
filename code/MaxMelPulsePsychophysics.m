% MaxMelPulsePsychophysics
%
% Description:
%   Define the parameters for the MaxPulsePsychophysics protocol of the
%   OLApproach_Psychophysics approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% 6/28/17  dhb  Added first history comment.
%          dhb  Move params.photoreceptorClasses into the dictionaries.
%          dhb  Move params.useAmbient into the dictionaries.

%% Clear
clear; close all;

%% Set the parameter structure here
% This controls the operation of this protocol.
%

d = ModulationParamsDictionary();
protocolParams = d('Modulation-PulseMaxLMS_3s_MaxContrast3sSegment');
% Who we are
protocolParams.approach = 'OLApproach_Psychophysics';
protocolParams.protocol = 'MaxMelPulsePsychophysics';
protocolParams.protocolType = 'PulseRating';

% Simulate?
protocolParams.simulate = false;

% Photoreceptor parameters, assume a dialated pupil
protocolParams.fieldSizeDegrees = 27.5;
protocolParams.pupilDiameterMm = 8; 

% WHAT DO THESE DO?
protocolParams.CALCULATE_SPLATTER = false;
protocolParams.maxPowerDiff = 10^(-1);

% WHAT DOES THIS DO?
protocolParams.isActive = 1;
        
% OneLight parameters
protocolParams.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND02';
protocolParams.takeTemperatureMeasurements = false;
protocolParams.spectroRadiometerOBJWillShutdownAfterMeasurement = false;

% Information we prompt for and related
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocolParams.observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
protocolParams.todayDate = datestr(now, 'mmddyy');

%% Initialize the one light
% 
% HOW DOES ol GET TO THE ROUTINES BELOW?  WHO CLOSES OL?
ol = OneLight('simulate',protocolParams.simulate);

%% Open the session
protocolParams = Psychophysics.SessionLog(protocolParams,'SessionInit');

%% Make the corrected modulation primaries
protocolParams = Psychophysics.MakeDirectionCorrectedPrimaries(protocolParams);

%% Make the Starts and Stops
protocolParams = Psychophysics.MakeModulationStartsStops(protocolParams);

%% Validate Direction Corrected Primaries Prior to Experiemnt
protocolParams = Psychophysics.ValidateDirectionCorrectedPrimaries(protocolParams,'Pre');

%% Run Demo Code
protocolParams = Psychophysics.Demo(protocolParams);

%% Run Experiment
protocolParams = Psychophysics.Experiment(protocolParams);

%% Validate Direction Corrected Primaries Post Experiment
protocolParams = Psychophysics.ValidateDirectionCorrectedPrimaries(protocolParams,'Post');