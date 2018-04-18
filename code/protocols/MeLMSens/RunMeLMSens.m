%% Run MeLMSens protocol

%% Set overall parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
if exist('radiometer','var')
    try radiometer.shutDown
    end
end
clear all; close all; clc;

approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Set output path
participantID = GetWithDefault('>> Enter <strong>participant ID</strong>', 'HERO_xxxx');
participantAge = GetWithDefault('>> Enter <strong>participant age</strong>', 32);
sessionName = GetWithDefault('>> Enter <strong>session number</strong>:', 'session_1');
todayDate = datestr(now, 'yyyy-mm-dd');
protocolDataPath = getpref(protocol,'DataFilesBasePath');
participantDataPath = fullfile(protocolDataPath,participantID);
sessionDataPath = fullfile(participantDataPath,[todayDate '_' sessionName]);
mkdir(sessionDataPath);

%% Set condition parameters 
% Define constant params:
pulseDuration = {4};      % s
flickerDuration = {.250}; % s
flickerFrequency = {25};  % Hz
flickerContrast = {.025}; 

% Define independent variables:
pulseContrast = {0, 3};
flickerLag = {0, 1.0};    % s

%% Get calibration
% Specify which box and calibration to use, check that everything is set up
% correctly, and retrieve the calibration structure.
boxName = 'BoxD';
calibrationType = 'BoxDRandomizedLongCableBEyePiece2_ND01';
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',calibrationType,'CalibrationDate','latest');

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~simulate.radiometer
    oneLight.setAll(true);
    commandwindow;
    input('<strong>Focus the radiometer and press enter to pause 3 seconds and start measuring.</strong>\n');
    oneLight.setAll(false);
    pause(3);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Create directions
% Melanopsin isolating direction
melDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
melDirectionParams.primaryHeadRoom = 0;
melDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3);
[MelDirection, background] = OLDirectionNominalFromParams(melDirectionParams, calibration, 'observerAge', participantAge);
LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
LMSDirectionParams.primaryHeadRoom = 0;
LMSDirectionParams.modulationContrast = [.06 .06 .06];
LMSDirection(4) = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', background+MelDirection, 'observerAge', participantAge);
LMSDirection(1) = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'background', background, 'observerAge', participantAge);
receptors = LMSDirection(1).describe.directionParams.T_receptors;
background.describe.T_receptors = receptors;

%% Validate the directions
% Desired contrasts
nominalMaxMelContrast = ToDesiredReceptorContrast(MelDirection,background, receptors);
nominalMaxLMSContrastOnMel = ToDesiredReceptorContrast(LMSDirection(4), background+MelDirection, receptors);
nominalMaxLMSContrastOnBackground = ToDesiredReceptorContrast(LMSDirection(1), background+MelDirection, receptors);

% Pre-correction validation of background
OLValidateDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer, 'receptors', receptors,'label','pre-correction');

% Pulse at receptor contrast levels
OLValidateDirection(MelDirection, background, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction max contrast');
for c = 1:numel(pulseContrast)
    % Scale to receptor contrast level, validate, add to MelDirection
    % validations
    MelDirection.describe.validation = [MelDirection.describe.validation ...
        OLValidateDirection(ScaleToReceptorContrast(MelDirection,background,receptors,[0 0 0 pulseContrast{c}]'),...
        background, oneLight, radiometer, 'receptors', receptors, 'label',sprintf('pre-correction %d%% contrast',c*100))];
end

% LMS at max mel contrast
OLValidateDirection(LMSDirection(4), background+MelDirection, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction max contrast');

% LMS on background
OLValidateDirection(LMSDirection(1), background, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction max contrast');

%% Correct (and re-validate)
% OLCorrectDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer);
% OLCorrectDirection(MelDirection, background, oneLight, radiometer);
% OLCorrectDirection(LMSDirection, background+MelDirection, oneLight, radiometer);
% 
% % Post-correction validation
% OLValidateDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer, 'receptors', receptors,'label','post-correction');
% 
% % Pulse at contrast levels
% OLValidateDirection(MelDirection, background, oneLight, radiometer, 'receptors', receptors, 'label','pre-correction max contrast');
% for c = pulseContrastLevels
%     % Scale to receptor contrast level, validate, add to MelDirection
%     % validations
%     MelDirection.describe.validation = [MelDirection.describe.validation ...
%         OLValidateDirection(ScaleToReceptorContrast(MelDirection,background,receptors,[0 0 0 c]'),...
%         background, oneLight, radiometer, 'receptors', receptors, 'label',sprintf('post-correction %d%% contrast',c*100))];
% end
% 
% % LMS at max contrast
% OLValidateDirection(LMSDirection, background+MelDirection, oneLight, radiometer, 'receptors', receptors, 'label','post-correction max contrast');

%% Unhook radiometer
% We don't need the radiometer for now, so allow the user to unhook the
% eyepiece from the radiometer, and set it up for viewing.
if ~simulate.radiometer
    oneLight.setAll(false);
    commandwindow;
    input(sprintf('<strong>Unhook the eyepiece from the radiometer and set up for viewing. Press enter to continue</strong>\n'));
end

%% Get gamepad
gpad = GamePad;

%% Generate conditionParamsList
% Generate conditionParamsList by crossing variables
conditionParamsList = crossVariables(pulseDuration, flickerDuration, flickerFrequency, flickerContrast, pulseContrast, flickerLag);
conditionParamsList = cell2struct(conditionParamsList,{'pulseDuration','flickerDuration','flickerFrequency','flickerContrast','pulseContrast','flickerLag'},2);

% Repeats
nRepeatsCondition = 2;
conditionParamsList = repmat(conditionParamsList,[nRepeatsCondition,1]);

% Shuffle
RNGSettings = rng; % save random number generator settings
conditionParamsList = Shuffle(conditionParamsList);

%% Demo/practice
% Assemble practice modulation
practiceModulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection(1), receptors, ...
    pulseDuration{1}, 0, 0, flickerDuration{1}, flickerFrequency{1}, .05);

% Set to background, for adaptation
[backgroundStarts, backgroundStops] = OLPrimaryToStartsStops(background.differentialPrimaryValues, background.calibration);
oneLight.setMirrors(backgroundStarts, backgroundStops);
WaitForKeyPress;

% Display practice modulation
OLFlicker(oneLight,practiceModulation.starts,practiceModulation.stops,practiceModulation.timestep, 1);
oneLight.setMirrors(backgroundStarts, backgroundStops);
WaitForKeyPress;

%
sessionResults = table();

%% Run trial loop
for c = 1:numel(conditionParamsList)
    modulationParams = conditionParamsList(c);
    modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection(modulationParams.pulseContrast+1),...
            modulationParams);
    acquisitionStart = mglGetSecs;
        
    % Set to background, for adaptation
    Speak('Adapting to background. Press key to continue');
    oneLight.setMirrors(backgroundStarts, backgroundStops);
    WaitForKeyPress;

    % Method of adjustment loop
    accept = false;
    while ~accept
        % Set OneLight to background
        oneLight.setMirrors(backgroundStarts, backgroundStops);

        % Assemble stimulus for this trial
        modulation = AssembleModulation_MeLMS(background, MelDirection, LMSDirection(modulationParams.pulseContrast+1),...
            modulationParams);

        % Display stimulus
        OLFlicker(oneLight,modulation.starts,modulation.stops,modulation.timestep, 1);
        oneLight.setMirrors(backgroundStarts, backgroundStops);
        beep;
        
        % Process response
        resume = false;
        while ~resume
            WaitForKeyPress;
            key = gpad.getKeyEvent;

            % Update params
            switch key.charCode
                case 'GP:LowerRightTrigger'
                    if modulationParams.flickerContrast < .05
                        modulationParams.flickerContrast = modulationParams.flickerContrast + .001;
                        resume = true;
                    else
                        beep;
                    end
                case 'GP:LowerLeftTrigger'
                    if modulationParams.flickerContrast > .001
                        modulationParams.flickerContrast = modulationParams.flickerContrast - .001;
                        resume = true;
                    else
                        beep;
                    end
                case 'GP:A'
                    accept = true;
                    Speak('Acquisition finished');
                    resume = true;
            end
        end
    end
    oneLight.setMirrors(backgroundStarts, backgroundStops);
    
    % Validate scaled directions post acquisition
%     FlushEvents;
%     fprintf('<strong>Focus the radiometer and press any key to start measuring.</strong>\n'); 
%     keyboard;
%     scaledMel = ScaleToReceptorContrast(MelDirection, background, receptors, [0 0 0 modulationParams.pulseContrast]');
%     scaledLMS = ScaleToReceptorContrast(LMSDirection, background+scaledMel, receptors, [modulationParams.flickerContrast modulationParams.flickerContrast modulationParams.flickerContrast 0]');
%     nominalScaledMelContrast = ToDesiredReceptorContrast(scaledMel,background, receptors);
%     nominalScaledLMSContrast = ToDesiredReceptorContrast(scaledLMS, background+MelDirection, receptors);
%     backgroundValidation = OLValidateDirection(background, OLDirection_unipolar.Null(calibration), oneLight, radiometer, 'receptors', receptors,'label','threshold-setting');
%     scaledMelValidation = OLValidateDirection(scaledMel, background, oneLight, radiometer, 'receptors', receptors, 'label','threshold-setting');
%     scaledLMSValidation = OLValidateDirection(scaledLMS, background+scaledMel, oneLight, radiometer, 'receptors', receptors, 'label','threshold-setting');
%     fprintf('<strong>Unhook the eyepiece from the radiometer and set up for viewing. Press any key to continue</strong>\n');  WaitForKeyPress;
    
    % Save out
    acquisitionResults = struct2table(modulationParams);
    acquisitionResults.Properties.VariableNames{'pulseContrast'} = 'pulseContrastNominal';
    acquisitionResults.Properties.VariableNames{'flickerContrast'} = 'flickerContrastNominal';
%     acquisitionResults.pulseContrastActual = scaledMelValidation.contrastActual(:,1)';
%     acquisitionResults.flickerContrastActual = scaledLMSValidation.contrastActual(:,1)';
    acquisitionResults.participantID = participantID;
    acquisitionResults.session = sessionName;
    acquisitionResults.date = todayDate;    
    acquisitionResults.startTime = acquisitionStart;
    acquisitionResults.stopTime = mglGetSecs;
    sessionResults = [sessionResults; acquisitionResults];
    writetable(sessionResults,fullfile(sessionDataPath,['results-' participantID '-' sessionName '.csv']));
    save(fullfile(sessionDataPath,['data-' participantID '-' sessionName '.mat']),...
        'sessionResults','background','MelDirection','LMSDirection','calibration');
end 
%% Close radiometer
if exist('radiometer','var') && ~isempty(radiometer)
    radiometer.shutDown()
end

%% Close OneLight
shutdown = input('<strong>Shutdown OneLight? [Y/N]</strong>','s');
if upper(shutdown) == 'Y'
    oneLight.shutdown()
end
oneLight.close();