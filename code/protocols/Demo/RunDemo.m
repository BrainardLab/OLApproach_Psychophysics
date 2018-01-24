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

% Modulations used in this experiment.  
%
% Each row of the trialMatrix cell array specifies one trial type.  The
% columns provide specifics, as follows.
%   trialNum            - Trial type number
%   directionName       - Name of direction file to be used
%   modulationName      - Name of modulation dictionary entry.
%   directionType       - Type of direction
%   trialTypeParams     - These override standard information in [FIGURE ME
%                         OUT.]
%   doCorrectionAndValidationFlag - Correct and validate direction.
%                         Otherwise use nominal values and don't validate.
%   correctBySimulation - If correct and validate is true, can correct
%                         using simulation (which will not change
%                         primaries), but still validate.
%
% Do not change the order of these directions without also fixing up
% the Demo and Experimental programs, which are counting on this order.
trialMatrix = {...
    1,'MaxLMS_275_80_667','MaxContrast3sSinusoid','pulse',struct('contrast',1),true,true;...
    2,'MaxMel_275_80_667','MaxContrast3sPulse','pulse',struct('contrast',1),true,true;...
    3,'LightFlux_540_380_50','MaxContrast3sPulse','lightfluxchrom',struct('contrast',1),true,true;...
    };
trialParamsList = cell2struct(trialMatrix,...
    {'trialNum','directionName','modulationName','directionType','trialTypeParams','doCorrectionAndValidationFlag','correctBySimulation'},2);

protocolParams.directionNames = {trialParamsList.directionName};
protocolParams.modulationNames = {trialParamsList.modulationName};
protocolParams.directionTypes = {trialParamsList.directionType};
protocolParams.trialTypeParams = [trialParamsList.trialTypeParams];
protocolParams.doCorrectionAndValidationFlag = {trialParamsList.doCorrectionAndValidationFlag};
protocolParams.correctBySimulation = [trialParamsList.correctBySimulation];

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
protocolParams.AdaptTimeSecs = 1; 
protocolParams.nRepeatsPerStimulus = 2;
      
% OneLight parameters
protocolParams.boxName = 'BoxA';  
protocolParams.calibrationType = 'OLDemoCal';
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTemperatureMeasurements = false;

% Validation parameters
protocolParams.nValidationsPerDirection = 2;

% Spectrum Seeking: /MELA_data/Experiments/OLApproach_Psychophysics/DirectionCorrectedPrimaries/DEMO/1970-01-01/demo_session/...
% Validation: /MELA_data/Experiments/OLApproach_Psychophysics/DirectionValidationFiles/DEMO/1970-01-01/demo_session/...
protocolParams.observerID = 'DEMO';
protocolParams.observerAgeInYrs = 32;
protocolParams.todayDate = '1970-01-01';

% Sanity check on modulations
if (length(protocolParams.modulationNames) ~= length(protocolParams.directionNames))
    error('Modulation and direction names cell arrays must have same length');
end

%% Open the session
%
% The call to OLSessionLog sets up info in protocolParams for where
% the logs go.
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

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

%% Make the corrected modulation primaries
OLMakeDirectionCorrectedPrimaries(ol,protocolParams,'verbose',protocolParams.verbose);

%% Make the modulation starts and stops
OLMakeModulationStartsStops(protocolParams.modulationNames,protocolParams.directionNames, protocolParams,'verbose',protocolParams.verbose);

%% Validate direction corrected primaries prior to experiemnt
OLValidateDirectionCorrectedPrimaries(ol,protocolParams,'Pre');
OLAnalyzeDirectionCorrectedPrimaries(protocolParams,'Pre');

%% Load
trialList = struct([]);
modulationDir = fullfile(getpref(protocolParams.protocol, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);
for trialNum = 1:size(trialParamsList,1)
    trial = trialParamsList(trialNum);
    trial.modulationName = sprintf('ModulationStartsStops_%s_%s_trialType_%d', trial.modulationName, trial.directionName, trial.trialNum);
    trial.path = [trial.modulationName '.mat'];
    trial.modulation = load(fullfile(modulationDir, trial.path),'modulationData');
    trial.modulationData = trial.modulation.modulationData.modulation;
    trial.backgroundStarts = trial.modulationData.background.starts;
    trial.backgroundStops = trial.modulationData.background.stops;
    trial.modulationStarts = trial.modulationData.starts;
    trial.modulationStops = trial.modulationData.stops;
    trial.timestep = trial.modulation.modulationData.modulationParams.timeStep;
    
    trialList = [trialList trial];
end

%% Run demo code
DemoEngine(trialList,ol,protocolParams);

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
