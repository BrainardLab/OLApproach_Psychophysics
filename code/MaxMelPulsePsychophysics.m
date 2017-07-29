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
% These four arrays should have the same length, the entries get paired.
protocolParams.modulationNames = {'MaxContrast3sSegment' ...
                                  'MaxContrast3sSegment' ...
                                  'MaxContrast3sSegment' ...
                                  };
protocolParams.directionNames = {...
    'MaxMel_275_80_667' ...
    'MaxLMS_275_80_667' ...
    'LightFlux_540_380_50' ...
    };
protocolParams.directionTypes = {...
    'pulse' ...
    'pulse' ...
    'lightfluxpulse' ...
    };
protocolParams.directionsCorrect = [...
    true ...
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
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTemperatureMeasurements = true;

% Validation parameters
protocolParams.nValidationsPerDirection = 2;

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

%% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate); drawnow;

%% Let user get the radiometer set up
radiometerPauseDuration = 0;
ol.setAll(true);
commandwindow;
fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
input('');
ol.setAll(false);
pause(radiometerPauseDuration);

%% Open the session
%
% The call to OLSessionLog sets up info in protocolParams for where
% the logs go.
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

%% Make the corrected modulation primaries
OLMakeDirectionCorrectedPrimaries(ol,protocolParams,'verbose',protocolParams.verbose);
% OLAnalyzeValidationReceptorIsolate(validationPath, 'short');
% % Compute and print out information about the quality of
% % the current measurement, in contrast terms.
% theCanonicalPhotoreceptors = cacheData.data(correctionDescribe.observerAgeInYrs).describe.photoreceptors;
% T_receptors = cacheData.data(correctionDescribe.observerAgeInYrs).describe.T_receptors;
% [contrasts(:,iter) postreceptoralContrasts(:,iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
%     backgroundSpdMeasured,modulationSpdMeasured,correctionDescribe.postreceptoralCombinations,true);

%% Make the modulation starts and stops
OLMakeModulationStartsStops(protocolParams.modulationNames,protocolParams.directionNames, protocolParams,'verbose',protocolParams.verbose);

%% Validate direction corrected primaries prior to experiemnt
OLValidateDirectionCorrectedPrimaries(ol,protocolParams,'Pre');
% OLAnalyzeValidationReceptorIsolate(validationPath, validationDescribe.postreceptoralCombinations);

%% Run demo code
Psychophysics.Demo(ol,protocolParams);

%% Run experiment
Psychophysics.Experiment(ol,protocolParams);

%% Let user get the radiometer set up
ol.setAll(true);
commandwindow;
fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
input('');
ol.setAll(false);
pause(radiometerPauseDuration);

%% Validate direction corrected primaries post experiment
OLValidateDirectionCorrectedPrimaries(ol,protocolParams,'Post');
% OLAnalyzeValidationReceptorIsolate(validationPath, validationDescribe.postreceptoralCombinations);
