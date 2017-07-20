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

% Who we are
protocolParams.approach = 'OLApproach_Psychophysics';
protocolParams.protocol = 'MaxMelPulsePsychophysics';
protocolParams.protocolType = 'PulseRating';

% Modulations used in this experiment
% 
% These two cell arrays should have teh same length - the modulations get paired 
% with the directions in a one-to-one way.
protocolParams.modulationNames = {'Modulation_MaxContrast3sSegment', ...
                                  'Modulation_MaxContrast3sSegment'};
protocolParams.directionNames = {...
    'MaxLMS' ...
    'MaxMel' ...
    };
if (length(protocolParams.modulationNames) ~= protocolParams.directionNames)
    error('Modulation and direction names cell arrays must have same length');
end
                               
% Simulate?
protocolParams.simulate = false;

% Photoreceptor parameters, assume a dialated pupil
protocolParams.fieldSizeDegrees = 27.5;
protocolParams.pupilDiameterMm = 8; 
protocolParams.baseModulationContrast = 4/6;
protocolParams.maxPowerDiff = 10^(-1);
protocolParams.primaryHeadroom = 0.01;
      
% OneLight parameters
protocolParams.calibrationType = 'BoxBRandomizedLongCableBEyePiece1_ND03';
protocolParams.takeTemperatureMeasurements = false;
protocolParams.spectroRadiometerOBJWillShutdownAfterMeasurement = false;

% Information we prompt for and related
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocolParams.observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
protocolParams.todayDate = datestr(now, 'mmddyy');

%% Check that prefs are as expected
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(theApproach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end

%% Initialize the one light
% 
% HOW DOES ol GET TO THE ROUTINES BELOW?  WHO CLOSES OL?
ol = OneLight('simulate',protocolParams.simulate);

%% Open the session
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

%% Make the corrected modulation primaries
protocolParams = OLMakeDirectionCorrectedPrimaries(protocolParams);

%% Make the Starts and Stops
OLMakeModulationStartsStops(protocolParams.modulationNames,protocolParams.directionNames, protocolParams);

%% Validate Direction Corrected Primaries Prior to Experiemnt
protocolParams = OLValidateDirectionCorrectedPrimaries(protocolParams,'Pre');

%% Run Demo Code
protocolParams = Psychophysics.Demo(protocolParams);

%% Run Experiment
protocolParams = Psychophysics.Experiment(protocolParams);

%% Validate Direction Corrected Primaries Post Experiment
protocolParams = OLValidateDirectionCorrectedPrimaries(protocolParams,'Post');