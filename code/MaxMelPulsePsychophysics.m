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
% Who we are
protocoalParams.approach = 'OLApproach_Psychophysics';
protocoalParams.protocol = 'MaxMelPulsePsychophysics';
protocoalParams.protocolType = 'PulseRating';

% Simulate?
protocoalParams.simulate = false;

% Photoreceptor parameters, assume a dialated pupil
protocoalParams.fieldSizeDegrees = 27.5;
protocoalParams.pupilDiameterMm = 8; 

% WHAT DO THESE DO?
protocoalParams.CALCULATE_SPLATTER = false;
protocoalParams.maxPowerDiff = 10^(-1);

% WHAT DOES THIS DO?
protocoalParams.isActive = 1;
        
% OneLight parameters
protocoalParams.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND02';
protocoalParams.takeTemperatureMeasurements = false;
protocoalParams.spectroRadiometerOBJWillShutdownAfterMeasurement = false;

% Information we prompt for and related
protocoalParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocoalParams.observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
protocoalParams.todayDate = datestr(now, 'mmddyy');

%% Initialize the one light
% 
% HOW DOES ol GET TO THE ROUTINES BELOW?  WHO CLOSES OL?
ol = OneLight('simulate',protocoalParams.simulate);

%% Open the session
protocoalParams = Psychophysics.SessionLog(protocoalParams,'SessionInit');

%% Make the nominal modulation primaries
Psychophysics.MakeDirectionNominalPrimaries(protocoalParams);

%% Make the corrected modulation primaries
Psychophysics.MakeDirectionCorrectedPrimaries(protocoalParams);

%% Make the Starts and Stops
Psychophysics.MakeModulationStartsStops(protocoalParams);

%% Validate Direction Corrected Primaries
Psychophysics.ValidateDirectionCorrectedPrimaries(protocoalParams);