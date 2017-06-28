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
params.approach = 'OLApproach_Psychophysics';
params.protocol = 'MaxMelPulsePsychophysics';
params.protocolType = 'PulseRating';

% Simulate?
params.simulate = false;

% Photoreceptor parameters, assume a dialated pupil
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8; 

% WHAT DO THESE DO?
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
               
params.isActive = 1;
 
          
% OneLight parameters
params.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND02';
params.takeTemperatureMeasurements = false;
params.spectroRadiometerOBJWillShutdownAfterMeasurement = false;

% Information we prompt for and related
params.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
params.observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
params.todayDate = datestr(now, 'mmddyy');

%% Initialize the one light
% 
% HOW DOES ol GET TO THE ROUTINES BELOW?  WHO CLOSES OL?
ol = OneLight('simulate',params.simulate);

%% Open the session
params = Psychophysics.SessionLog(params,'SessionInit');

%% Make the nominal modulation primaries
Psychophysics.MakeDirectionNominalPrimaries(params);

%% Make the corrected modulation primaries
Psychophysics.MakeDirectionCorrectedPrimaries(params);

%% Make the Starts and Stops
Psychophysics.MakeModulationStartsStops(params);

%% Validate Direction Corrected Primaries
Psychophysics.ValidateDirectionCorrectedPrimaries(params);