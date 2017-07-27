% MaxMelPulsePsychophysics
%
% Description:
%   Define the parameters for the MaxPulsePsychophysics protocol of the
%   OLApproach_Psychophysics approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% 6/28/17  dhb  Added first history comment.
%          dhb  Move params.photoreceptorClasses into the dictionaries.
%          dhb  Move params.useAmbient into the dictionaries.

%% POWER LEVELS SHOULD COME OUT OF CORRECTION DICTIONARY AND INTO PROTOCOL.  POSSIBLY
%% INTO DIRECTION DICTIONARY.

%% Clear
clear; close all;

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_Psychophysics';
protocolParams.protocol = 'MaxMelPulsePsychophysics';
protocolParams.protocolType = 'PulseRating';
protocolParams.emailRecipient = 'jryan@mail.med.upenn.edu';
protocolParams.verbose = false;
protocolParams.simulate = true;

% Modulations used in this experiment
% 
% These two cell arrays should have teh same length - the modulations get paired 
% with the directions in a one-to-one way.
protocolParams.modulationNames = {'MaxContrast3sSegment', ...
                                  'MaxContrast3sSegment'};
protocolParams.directionNames = {...
    'MaxLMS' ...
    'MaxMel' ...
    };
protocolParams.directionTypes = {...
    'pulse' ...
    'pulse' ...
    };
protocolParams.directionsCorrect = [...
    true ...
    true ...
    ];

% Photoreceptor parameters, assume a dialated pupil
protocolParams.fieldSizeDegrees = 27.5;
protocolParams.pupilDiameterMm = 8; 
protocolParams.baseModulationContrast = 4/6;
protocolParams.maxPowerDiff = 10^(-1);
protocolParams.primaryHeadroom = 0.01;
      
% OneLight parameters
protocolParams.boxName = 'BoxB';  
protocolParams.calibrationType = 'BoxBRandomizedLongCableBEyePiece1_ND03';
protocolParams.takeTemperatureMeasurements = false;
protocolParams.spectroRadiometerOBJWillShutdownAfterMeasurement = false;

% Information we prompt for and related
commandwindow;
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocolParams.observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
protocolParams.todayDate = datestr(now, 'mmddyy');

%% Check that prefs are as expected, as well as some parameter sanity checks/adjustments
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end

% Sanity check on modulations
if (length(protocolParams.modulationNames) ~= length(protocolParams.directionNames))
    error('Modulation and direction names cell arrays must have same length');
end
                               
% Handle simulation case for corrections by setting directions correct
if (protocolParams.simulate)
    for ii = 1:length(protocolParams.directionsCorrect)
        protocolParams.directionsCorrect(ii) = false;
    end
end

%% Open the session
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

%% Make the corrected modulation primaries
protocolParams = OLMakeDirectionCorrectedPrimaries(protocolParams,'verbose',protocolParams.verbose);

%% Make the modulation starts and stops
OLMakeModulationStartsStops(protocolParams.modulationNames,protocolParams.directionNames, protocolParams,'verbose',protocolParams.verbose);

%% Validate direction corrected primaries prior to experiemnt
protocolParams = OLValidateDirectionCorrectedPrimaries(protocolParams,'Pre');

%% Run demo code
protocolParams = Psychophysics.Demo(protocolParams);

%% Run experiment
protocolParams = Psychophysics.Experiment(protocolParams);

%% Validate direction corrected primaries post experiment
protocolParams = OLValidateDirectionCorrectedPrimaries(protocolParams,'Post');