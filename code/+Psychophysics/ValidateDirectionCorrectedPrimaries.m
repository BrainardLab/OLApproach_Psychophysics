% MaxPulsePsychophycis_ValidateCorrectedPrimaries - Measure and check the corrected primaries
%
% Description:
%     This script uses the radiometer to measure the light coming out of the eyepiece and 
%     calculates the receptor contrasts.  This is a check on how well we
%     are hitting our desired target.  Typically we run this before and
%     after the experimental session.

% 6/18/17  dhb  Added header comment.



% Assign the default choice index the first time we run this script. We
% clear this after the pre-experimental validation.
choiceIndex = 1;

tic;
commandwindow;

% Prompt the user to state if we're before or after the experiment
if ~exist('choiceIndex', 'var')
    choiceIndex = ChoiceMenuFromList({'Before the experiment', 'After the experiment'}, '> Validation before or after the experiment?');
end

% Ask for variables if they don't exist
if ~exist('observerID', 'var') || ~exist('observerAgeInYrs', 'var') || ~exist('todayDate', 'var') || ~exist('takeTemperatureMeasurements', 'var')
    observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
    observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
    todayDate = GetWithDefault('>> Enter <strong>date of modulations were created</strong>:', 'mmddyy');
    takeTemperatureMeasurements = true;
end

% Set up some parameters
theCalType = 'OLDemoCal';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {['Cache-MelanopsinDirectedSuperMaxMel_' observerID '_' todayDate '.mat'] ...
    ['Cache-LMSDirectedSuperMaxLMS_' observerID '_' todayDate '.mat']};
NDirections = length(theDirections);
cacheDir = getpref('MaxPulsePsychophysics', 'DirectionCorrectedPrimariesDir');
materialsPath = getpref('OneLight', 'materialsPath');
NMeas = 5;

% Set up a counter
c = 1;
NTotalMeas = NMeas*NDirections;

for ii = 1:NMeas;
    for d = 1:NDirections
        % Inform the user where we are in the validation
        fprintf('*** Validation %g / %g in total ***\n', c, NTotalMeas);
        
        % We also take state measurements, which we define here
        if (choiceIndex == 1) && (c == 1)
            calStateFlag = true;
        elseif (choiceIndex == 2) && (c == NTotalMeas)
            calStateFlag = true;
        else
            calStateFlag = false;
        end
        
        % Take the measurement
        [~, ~, ~, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
            fullfile(cacheDir, theDirections{d}), ...
            'jryan@mail.med.upenn.edu', ...
            'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
            'FullOnMeas', false, ...
            'CalStateMeas', calStateFlag, ...
            'DarkMeas', false, ...
            'OBSERVER_AGE', observerAgeInYrs, ...
            'ReducedPowerLevels', false, ...
            'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, ...
            'powerLevels', [0 1.0000], ...
            'pr670sensitivityMode', 'STANDARD', ...
            'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
            'outDir', cacheDir, ... %'outDir', fullfile(materialsPath, 'MaxPulsePsychophysics', datestr(now, 'mmddyy')), ...
            'takeTemperatureMeasurements', takeTemperatureMeasurements);
        
        % Increment the counter
        c = c+1;
    end
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end
fprintf('\n************************************************');
fprintf('\n*** <strong>Validation all complete</strong> ***');
fprintf('\n************************************************\n');
toc;

% Clear the choiceIndex. Note that this is only relevant for the
% pre-experimental validations.
clear choiceIndex;