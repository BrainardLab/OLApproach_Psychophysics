% RunMaxMelPulsePsychophysics
%
% Description:
%   Define the parameters for the MaxPulsePsychophysics protocol of the
%   OLApproach_Psychophysics approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% 6/28/17  dhb  Added first history comment.
%          dhb  Move params.photoreceptorClasses into the dictionaries.
%          dhb  Move params.useAmbient into the dictionaries.
% 01/18/18 jv  Created RunDemo protocol as copy of legacy
%              RunMaxMelPulsePsychophysics

%% Setup into a good state for this protocol
clear; close all;
protocolParams.approach = 'OLApproach_Psychophysics';
protocolParams.protocol = 'MaxMelPulsePsychophysics';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end

%% Set the parameter structure here
%
% Who we are and what we're doing today

%protocolParams.protocolType = 'PulseRating';
%protocolParams.emailRecipient = 'joris.vincent@pennmedicine.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.protocolOutputName = '';
protocolParams.acquisitionNumber = 0;
%protocolParams.doCorrectionFlag = true;

% Modulations used in this experiment
% 
% Thee four arrays below should have the same length, the entries get paired.
%
% Do not change the order of these directions without also fixing up
% the Demo and Experimental programs, which are counting on this order.
protocolParams.modulationNames = {'MaxContrast3sPulse' ...
                                  'MaxContrast3sPulse' ...
                                  'MaxContrast3sPulse' ...
                                  };
protocolParams.directionNames = {...
    'MaxMel_275_80_667' ...
    'MaxLMS_275_80_667' ...
    'LightFlux_540_380_50' ...
    };
protocolParams.directionTypes = {...
    'pulse' ...
    'pulse' ...
    'lightfluxchrom' ...
    };
protocolParams.trialTypeParams = [...
    struct('contrast',1) ...
    struct('contrast',1) ...
    struct('contrast',1) ...
    ];
protocolParams.correctBySimulation = [...
    true ...
    true ...
    true ...
    ];
protocolParams.doCorrectionAndValidationFlag = {...
    true ...
    true ...
    true ...
    };

% Field size and pupil size.
%
% These are used to construct photoreceptors for validation for directions
% (e.g. light flux) where they are not available in the direction file.
% They can also be used to check for consistency.  
%
% If we ever want to run with more than one field size and pupil size in a single 
% run, this will need a little rethinking.
protocolParams.fieldSizeDegrees = 27.5;
protocolParams.pupilDiameterMm = 8;

% Timing things
protocolParams.demoAdaptTimeSecs = 1; 
protocolParams.experimentAdaptTimeSecs = 1;
      
% OneLight parameters
protocolParams.boxName = 'BoxA';  
protocolParams.calibrationType = 'OLDemoCal';
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTemperatureMeasurements = false;

% Validation parameters
protocolParams.nValidationsPerDirection = 2;

% Spectrum Seeking: /MELA_data/Experiments/OLApproach_Psychophysics/DirectionCorrectedPrimaries/Jimbo/081117/session_1/...
% Validation: /MELA_data/Experiments/OLApproach_Psychophysics/DirectionValidationFiles/Jimbo/081117/session_1/...
protocolParams.observerID = 'DEMO';
protocolParams.observerAgeInYrs = 32;
protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');
protocolParams.sessionName = 'demo_session';

% Sanity check on modulations
if (length(protocolParams.modulationNames) ~= length(protocolParams.directionNames))
    error('Modulation and direction names cell arrays must have same length');
end


%% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate.oneLight); drawnow;

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
OLAnalyzeDirectionCorrectedPrimaries(protocolParams,'Pre');

%% Run demo code
DemoEngine(ol,protocolParams);

%% Let user get the radiometer set up
ol.setAll(true);
commandwindow;
fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
input('');
ol.setAll(false);
pause(radiometerPauseDuration);

%% Validate direction corrected primaries post experiment
OLValidateDirectionCorrectedPrimaries(ol,protocolParams,'Post');
OLAnalyzeDirectionCorrectedPrimaries(protocolParams,'Post');
