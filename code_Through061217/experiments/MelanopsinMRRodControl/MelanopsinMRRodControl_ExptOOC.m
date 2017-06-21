%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ask for the observer age
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

% Query user whether to take temperature measurements
takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
if (takeTemperatureMeasurements ~= true) && (takeTemperatureMeasurements ~= 1)
   takeTemperatureMeasurements = false;
else
   takeTemperatureMeasurements = true;
end

%% Loop over the dim and bright cals
theCalTypeBright = 'BoxBRandomizedLongCableDStubby1_ND02';
theCalTypeDim = 'BoxBRandomizedLongCableDStubby1_ND02_ND40CassetteB';
theCals = {theCalTypeBright theCalTypeDim};

% Load the filter for the dim cal
S = [380 2 201];
theFilter = load(fullfile(getpref('OneLight', 'OneLightCalData'), 'xNDFilters', 'srf_filter_ND40CassetteB_100516'));
NDFilters = {ones(S(3), 1) theFilter.srf_filter_ND40CassetteB};

% Get the non-dim cal
cal0 = LoadCalFile(['OL' theCals{1}], [], getpref('OneLight', 'OneLightCalData'));

for cc = 1%:length(theCals);
    %% Set up the cal
    cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');
    cal = LoadCalFile(['OL' theCals{cc}], [], getpref('OneLight', 'OneLightCalData'));
    
    %% Load the cache files
    % MaxMel
    olCache1 = OLCache(cacheDir, cal);
    if ~isempty(strfind(theCals{cc}, 'ND40'))
        params1.modulationDirection = 'MelanopsinDirectedRodControlND40';
        params2.modulationDirection = 'LMinusMDirectedRodControlND40';
    else
        params1.modulationDirection = 'MelanopsinDirectedRodControl';
        params2.modulationDirection = 'LMinusMDirectedRodControl';
    end
    
    params1.cacheFile = ['Cache-' params1.modulationDirection '.mat'];
    cacheData1 = olCache1.load(params1.cacheFile);
    params1.cacheFile = ['Cache-' params1.modulationDirection '_' observerID '_' todayDate '.mat'];
    
    % L-M
    olCache2 = OLCache(cacheDir, cal);
    params2.cacheFile = ['Cache-' params2.modulationDirection '.mat'];
    cacheData2 = olCache2.load(params2.cacheFile);
    params2.cacheFile = ['Cache-' params2.modulationDirection '_' observerID '_' todayDate '.mat'];
    
    % Get the photoreceptors
    theCanonicalPhotoreceptors = cacheData1.data(observerAgeInYrs).describe.photoreceptors;
    T_receptors = cacheData1.data(observerAgeInYrs).describe.T_receptors;
    postreceptoralCombinations = [1 1 1 0 0 ; 1 -1 0 0 0 ; 0 0 1 0 0 ; 0 0 0 1 0 ; 0 0 0 0 1]; % LMS, L-M, S, Mel, Rod
    
    %% Correct the spectra
    primaryValues = [cacheData1.data(observerAgeInYrs).backgroundPrimary ...
        cacheData1.data(observerAgeInYrs).modulationPrimarySignedPositive ...
        cacheData1.data(observerAgeInYrs).modulationPrimarySignedNegative ...
        cacheData2.data(observerAgeInYrs).modulationPrimarySignedPositive ...
        cacheData2.data(observerAgeInYrs).modulationPrimarySignedNegative];
    NIter = 10;
    lambda = 0.8;
    meterType = 'PR-670';
    spectroRadiometerOBJ = [];
    spectroRadiometerOBJWillShutdownAfterMeasurement = true;
    
    % Run the correction
    if (takeTemperatureMeasurements)
        % With temperature measurements
        [correctedPrimaryValues primariesCorrectedAll deltaPrimariesCorrectedAll measuredSpd measuredSpdRaw predictedSpd temperatureData] = OLCorrectPrimaryValues(cal, cal0, primaryValues, NIter, lambda, NDFilters{cc}, ...
            meterType, spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, 'takeTemperatureMeasurements', true);
    else
        % Without temperature measurements
        [correctedPrimaryValues primariesCorrectedAll deltaPrimariesCorrectedAll measuredSpd measuredSpdRaw predictedSpd] = OLCorrectPrimaryValues(cal, cal0, primaryValues, NIter, lambda, NDFilters{cc}, ...
            meterType, spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement);
    end

    
    % Calculate the contrasts
    for iter = 1:NIter
        % Save out information about the correction
        [contrastsPositive1(:, iter) postreceptoralContrastsPositive1(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
            measuredSpd{1}(:, iter), measuredSpd{2}(:, iter), postreceptoralCombinations, true);
        [contrastsNegative1(:, iter) postreceptoralContrastsNegative1(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
            measuredSpd{1}(:, iter), measuredSpd{3}(:, iter), postreceptoralCombinations, true);
        [contrastsPositive2(:, iter) postreceptoralContrastsPositive2(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
            measuredSpd{1}(:, iter), measuredSpd{4}(:, iter), postreceptoralCombinations, true);
        [contrastsNegative2(:, iter) postreceptoralContrastsNegative2(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
            measuredSpd{1}(:, iter), measuredSpd{5}(:, iter), postreceptoralCombinations, true);
        GetLuminanceAndTrolandsFromSpd(S, measuredSpd{1}(:, end), cacheData1.data(observerAgeInYrs).describe.params.pupilDiameterMm, true);
    end
    
    % Replace the values in the cache files
    for ii = 1:length(cacheData1.data)
        if ii == observerAgeInYrs;
            cacheData1.data(ii).backgroundPrimary = correctedPrimaryValues(:, 1);
            cacheData1.data(ii).modulationPrimarySignedPositive = correctedPrimaryValues(:, 2);
            cacheData1.data(ii).modulationPrimarySignedNegative = correctedPrimaryValues(:, 3);
            cacheData1.data(ii).differencePrimary = cacheData1.data(ii).modulationPrimarySignedPositive - cacheData1.data(ii).backgroundPrimary;
            cacheData1.data(ii).correction.backgroundPrimaryCorrectedAll = primariesCorrectedAll{1};
            cacheData1.data(ii).correction.deltaBackgroundPrimaryInferredAll = deltaPrimariesCorrectedAll{1};
            cacheData1.data(ii).correction.bgSpdAll = measuredSpd{1};
            cacheData1.data(ii).correction.modulationPrimaryPositiveCorrectedAll = primariesCorrectedAll{2};
            cacheData1.data(ii).correction.deltaModulationPrimaryPositveInferredAll = deltaPrimariesCorrectedAll{2};
            cacheData1.data(ii).correction.modPositiveSpdAll = measuredSpd{2};
            cacheData1.data(ii).correction.modulationPrimaryNegativeCorrectedAll = primariesCorrectedAll{3};
            cacheData1.data(ii).correction.deltaModulationPrimaryNegativeInferredAll = deltaPrimariesCorrectedAll{3};
            cacheData1.data(ii).correction.modNegativeSpdAll = measuredSpd{3};
            cacheData1.data(ii).correction.contrastsPositive = contrastsPositive1;
            cacheData1.data(ii).correction.postreceptoralContrastsPositive = postreceptoralContrastsPositive1;
            cacheData1.data(ii).correction.contrastsNegative = contrastsNegative1;
            cacheData1.data(ii).correction.postreceptoralContrastsNegative = postreceptoralContrastsNegative1;
            cacheData1.data(ii).correction.NDFilter = NDFilters{cc};
        else
            cacheData1.data(ii).describe = [];
            cacheData1.data(ii).backgroundPrimary = [];
            cacheData1.data(ii).backgroundSpd = [];
            cacheData1.data(ii).differencePrimary = [];
            cacheData1.data(ii).differenceSpd = [];
            cacheData1.data(ii).modulationPrimarySignedPositive = [];
            cacheData1.data(ii).modulationPrimarySignedNegative = [];
            cacheData1.data(ii).modulationSpdSignedPositive = [];
            cacheData1.data(ii).modulationSpdSignedNegative = [];
            cacheData1.data(ii).ambientSpd = [];
            cacheData1.data(ii).operatingPoint = [];
            cacheData1.data(ii).computeMethod = [];
        end
    end
    
    for ii = 1:length(cacheData2.data)
        if ii == observerAgeInYrs;
            cacheData2.data(ii).backgroundPrimary = correctedPrimaryValues(:, 1);
            cacheData2.data(ii).modulationPrimarySignedPositive = correctedPrimaryValues(:, 4);
            cacheData2.data(ii).modulationPrimarySignedNegative = correctedPrimaryValues(:, 5);
            cacheData2.data(ii).differencePrimary = cacheData2.data(ii).modulationPrimarySignedPositive - cacheData2.data(ii).backgroundPrimary;
            cacheData2.data(ii).correction.backgroundPrimaryCorrectedAll = primariesCorrectedAll{1};
            cacheData2.data(ii).correction.deltaBackgroundPrimaryInferredAll = deltaPrimariesCorrectedAll{1};
            cacheData2.data(ii).correction.bgSpdAll = measuredSpd{1};
            cacheData2.data(ii).correction.modulationPrimaryPositiveCorrectedAll = primariesCorrectedAll{4};
            cacheData2.data(ii).correction.deltaModulationPrimaryPositveInferredAll = deltaPrimariesCorrectedAll{4};
            cacheData2.data(ii).correction.modPositiveSpdAll = measuredSpd{4};
            cacheData2.data(ii).correction.modulationPrimaryNegativeCorrectedAll = primariesCorrectedAll{5};
            cacheData2.data(ii).correction.deltaModulationPrimaryNegativeInferredAll = deltaPrimariesCorrectedAll{5};
            cacheData2.data(ii).correction.modNegativeSpdAll = measuredSpd{5};
            cacheData2.data(ii).correction.contrastsPositive = contrastsPositive2;
            cacheData2.data(ii).correction.postreceptoralContrastsPositive = postreceptoralContrastsPositive2;
            cacheData2.data(ii).correction.contrastsNegative = contrastsNegative2;
            cacheData2.data(ii).correction.postreceptoralContrastsNegative = postreceptoralContrastsNegative2;
            cacheData2.data(ii).correction.NDFilter = NDFilters{cc};
        else
            cacheData2.data(ii).describe = [];
            cacheData2.data(ii).backgroundPrimary = [];
            cacheData2.data(ii).backgroundSpd = [];
            cacheData2.data(ii).differencePrimary = [];
            cacheData2.data(ii).differenceSpd = [];
            cacheData2.data(ii).modulationPrimarySignedPositive = [];
            cacheData2.data(ii).modulationPrimarySignedNegative = [];
            cacheData2.data(ii).modulationSpdSignedPositive = [];
            cacheData2.data(ii).modulationSpdSignedNegative = [];
            cacheData2.data(ii).ambientSpd = [];
            cacheData2.data(ii).operatingPoint = [];
            cacheData2.data(ii).computeMethod = [];
        end
    end
    
    %% Attach the temperature data collected during OLCorrectPrimaryValues
    if (takeTemperatureMeasurements)
        cacheData1.temperatureData = temperatureData;
        cacheData2.temperatureData = temperatureData;
    end

    %% Save out the corrected cache files
    OLReceptorIsolateSaveCache(cacheData1, olCache1, params1);
    OLReceptorIsolateSaveCache(cacheData2, olCache2, params2);
end

%%
customSuffix = ['_' observerID '_' todayDate];
% Normal light level
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinMRRodControl_BackgroundRodControl-12sStatic.cfg', observerAgeInYrs, theCalTypeBright, theCalTypeBright, [], customSuffix);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinMRRodControl_LMinusMDirectedRodControl-12sWindowed4HzModulation.cfg', observerAgeInYrs, theCalTypeBright, theCalTypeBright, [], customSuffix);
OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinMRRodControl_MelanopsinDirectedRodControl-12sWindowed4HzModulation.cfg', observerAgeInYrs, theCalTypeBright, theCalTypeBright, [], customSuffix);

% ND4.0
%OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinMRRodControlND40_BackgroundRodControlND40-12sStatic.cfg', observerAgeInYrs, theCalTypeDim, theCalTypeBright, [], customSuffix);
%OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinMRRodControlND40_LMinusMDirectedRodControlND40-12sWindowed4HzModulation.cfg', observerAgeInYrs, theCalTypeDim, theCalTypeBright, [], customSuffix);
%OLReceptorIsolateMakeModulationStartsStops('Modulation-MelanopsinMRRodControlND40_MelanopsinDirectedRodControlND40-12sWindowed4HzModulation.cfg', observerAgeInYrs, theCalTypeDim, theCalTypeBright, [], customSuffix);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Validate the spectrum before and after the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
commandwindow;

% Prompt the user to state if we're before or after the experiment
if ~exist('choiceIndex', 'var')
    choiceIndex = ChoiceMenuFromList({'Before the experiment', 'After the experiment'}, '> Validation before or after the experiment?');
end

% Ask for variables if they don't exist
if ~exist('observerID', 'var') || ~exist('observerAgeInYrs', 'var') || ~exist('todayDate', 'var')
    observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
    observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
    todayDate = datestr(now, 'mmddyy');
end

% Set up some parameters
theCalType = theCalTypeBright;
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {['Cache-MelanopsinDirectedRodControl_' observerID '_' todayDate '.mat'] ...
    ['Cache-LMinusMDirectedRodControl_' observerID '_' todayDate '.mat']};%
    %['Cache-MelanopsinDirectedRodControlND40_' observerID '_' todayDate '.mat'] ...
    %['Cache-LMinusMDirectedRodControlND40_' observerID '_' todayDate '.mat']};
NDirections = length(theDirections);
cacheDir = getpref('OneLight', 'cachePath');
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
        
        if d == 1
            calType = theCalTypeBright;
        elseif d == 2
            calType = theCalTypeBright;
        elseif d == 3
            calType = theCalTypeDim;
        elseif d == 4
            calType = theCalTypeDim;
        end
        
        % Take the measurement
        [~, ~, ~, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
            fullfile(cacheDir, 'stimuli', theDirections{d}), ...
            'igdalova@mail.med.upenn.edu', ...
            'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
            'FullOnMeas', false, ...
            'CalStateMeas', calStateFlag, ...
            'DarkMeas', false, ...
            'REFERENCE_OBSERVER_AGE', observerAgeInYrs, ...
            'ReducedPowerLevels', false, ...
            'selectedCalType', calType, ...
            'CALCULATE_SPLATTER', false, ...
            'powerLevels', [0 1.0000], ...
            'pr670sensitivityMode', 'STANDARD', ...
            'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
            'outDir', fullfile(materialsPath, 'MelanopsinMR_RodControl', datestr(now, 'mmddyy')), ...
            'takeTemperatureMeasurements', takeTemperatureMeasurements);
        % Increment the counter
        c = c+1;
    end
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end