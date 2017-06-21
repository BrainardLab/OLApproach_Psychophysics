function [cacheData, olCache, params, contrastVector] = OLReceptorIsolateFindPIPR(params, forceRecompute)
% OLReceptorIsolateFindPIPR - Computes the settings for the PIPR.
%
% Syntax:
% OLReceptorIsolateFindPIPR(params, forceRecompute)
%
% Input:
% params (struct) - Parameters struct as returned by OLReceptorIsolatePrepareConfig.
% forceRecompute (logical) - If true, forces a recompute of the data found
%     in the config file.  Only do this if the target spectra were changed.
%     Default: false
%
% Output:
% cacheData (struct)
% olCache (class)
% params (struct)
% contrastVector (vector) - contains the contrasts of the modulation for
%       the reference observer specified in the params.
%
% See also:
%   OLReceptorIsolateSaveCache, OLReceptorIsolatePrepareConfig
%
% 4/19/13   dhb, ms     Update for new convention for desired contrasts in routine ReceptorIsolate.
% 2/25/14   ms          Modularized.
% 7/16/14   ms          Reworked for PIPR.

% Setup the directories we'll use.  We count on the
% standard relative directory structure that we always
% use in our (BrainardLab) experiments.
baseDir = fileparts(fileparts(which('OLReceptorIsolateFindPIPR')));
configDir = fullfile(baseDir, 'config', 'stimuli');
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

if ~isdir(cacheDir)
    mkdir(cacheDir);
end

% Check if the cache file is active as defined in the config file. If not,
% we will not run the subsequent cache generated routines.
if ~params.isActive
    error('ERROR: Cache file not active as specified in configFile field /isActive/. Aborting.');
end

%% Parse some of the parameter fields
photoreceptorClasses = allwords(params.photoreceptorClasses, ',');

%% Load the calibration file.
cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName);
assert(~isempty(cal), 'OLReceptorIsolateFindPIPR:NoCalFile', 'Could not load calibration file: %s', ...
    OLCalibrationTypes.(params.calibrationType).CalFileName);
calID = OLGetCalID(cal);

%% Pull out S
S = cal.describe.S;

%% Pupil diameter. Our artificial pupil is 4.7 mm, so we set this to be 4.7 mm here.
pupilDiameterMm = 4.7; % mm

%% Create the cache object.
olCache = OLCache(cacheDir, cal);

% Create the cache file name.
[~, cacheFileName] = fileparts(params.cacheFile);

% Look to see if the cache data already exists.
cacheExists = olCache.exist(cacheFileName);

% If the cache already exists, we will assume that we're going to use the
% same target spectra unless the user flagged to recompute them.
if cacheExists && ~forceRecompute
    fprintf('- Loading cache file: %s.\n', cacheFileName);
    
    % Load the cache data.
    [cacheData, wasRecomputed] = olCache.load(cacheFileName);
    
    % If the data was recomputed, save it.  It would
    % have been recomputed if olCache detected that it was
    % stale.  The most likely cause for this is that the
    % current calibration is more recent than the one that
    % was stored when the cache was last computed.
    if wasRecomputed
        olCache.save(cacheFileName, cacheData);
    else
        fprintf('- Cache file up to date.\n');
    end
else
    % Check if we want to recompute
    if forceRecompute
        fprintf('- Force recompute flagged.\n');
    else
        fprintf('- Creating new cache file.\n');
    end
    
    % We want to create a directory structure if the params.CALCULATE_SPLATTER flag is on, to save the output there
    if params.CALCULATE_SPLATTER
        if ~exist(fullfile(cacheDir, cacheFileName))
            mkdir(fullfile(cacheDir, cacheFileName));
        end
        if ~exist(fullfile(cacheDir, cacheFileName, char(cal.describe.calType)))
            mkdir(fullfile(cacheDir, cacheFileName, char(cal.describe.calType)));
        end
        
        docDir = fullfile(cacheDir, cacheFileName, char(cal.describe.calType), strrep(strrep(cal.describe.date, ' ', '_'), ':', '_'));
        if ~exist(docDir)
            mkdir(docDir);
        end
    end
    
    %% Set up what will be common to all observer ages
    %% Pull out the 'M' matrix
    B_primary = cal.computed.pr650M;
    
    %% Set up some parameters for the optimization
    whichPrimariesToPin = [];       % Primaries we want to pin
    whichReceptorsToIgnore = params.whichReceptorsToIgnore;    % Receptors to ignore
    whichReceptorsToIsolate = params.whichReceptorsToIsolate;    % Receptors to stimulate
    whichReceptorsToMinimize = params.whichReceptorsToMinimize;
    
    % Peg desired contrasts
    if ~isempty(params.modulationContrast)
        desiredContrasts = params.modulationContrast;
    else
        desiredContrasts = [];
    end
    
    % Assign an empty 'ambientSpd' variable so that the ReceptorIsolate
    % code still works. As of Sep 2013 (i.e. SSMRI), we include the ambient measurements
    % in the optimization. This is defined in a flag in the stimulus .cfg
    % files.
    if params.useAmbient
        ambientSpd = cal.computed.pr650MeanDark;
    else
        ambientSpd = zeros(size(B_primary,1),1);
    end
    
    % If the 'ReceptorIsolate' mode does not exist, just use the standard one.
    % We will later make a call to the ReceptorIsolateWrapper function.
    if ~isfield(params, 'receptorIsolateMode')
        receptorIsolateMode = 'Standard';
    else
        receptorIsolateMode = params.receptorIsolateMode;
    end
    
    % Set the operating point for the background to half-on. The
    % corresponding field in the cache configs was added in July 2014, so
    % to ensure backwards compatibility, we make sure that the code doesn't
    % break here. If it's not defined in the config, we assume that it
    % should be half-on.
    if ~isfield(params, 'bgOperatingPoint')
        operatingPoint = 0.5;
        backgroundPrimary = operatingPoint*ones(size(B_primary,2),1);
    else
        operatingPoint = params.bgOperatingPoint;
        backgroundPrimary = operatingPoint*ones(size(B_primary,2),1);
    end
    
    % If no initial primary guess exists, we use the background for it.
    % This accounts for the possibility of matching the primaries between
    % different modulations while not touching the background. If it is not
    % defined, we use the background as the initial guess.
    if ~exist('initialPrimary', 'var')
        initialPrimary = backgroundPrimary;
    end
    
    
    fprintf('\n> Generating stimuli which isolate receptor classes');
    for i = 1:length(whichReceptorsToIsolate)
        fprintf('\n  - %s', photoreceptorClasses{whichReceptorsToIsolate(i)});
    end
    fprintf('\n> Generating stimuli which ignore receptor classes');
    if ~(length(whichReceptorsToIgnore) == 0)
        for i = 1:length(whichReceptorsToIgnore)
            fprintf('\n  - %s', photoreceptorClasses{whichReceptorsToIgnore(i)});
        end
    else
        fprintf('\n  - None');
    end
    
    if isfield(params, 'checkKlein') && params.checkKlein;
        fprintf('\nKlein check flagged\n')
        kleinLabel  = {'KleinX' , 'KleinY' , 'KleinZ'};
    end
    fprintf('\n');
    
    
    for observerAgeInYears = 20:60;
        %% Get the PIPR.
        switch params.modulationDirection
            case 'PIPR470'
                theWl = 470;
                targetFWHM = 20;
                
                % Figure out which primary corresponds to this.
                [~, i] = max((B_primary)); wls = SToWls(S);
                thePrimaryWls = wls(i);
                [~, thePrimaryIndex] = min(abs(thePrimaryWls-theWl));
                
                
            case 'PIPR623'
                theWl = 623;
                targetFWHM = 20;
                
                % Figure out which primary corresponds to this.
                [~, i] = max((B_primary)); wls = SToWls(S);
                thePrimaryWls = wls(i);
                [~, thePrimaryIndex] = min(abs(thePrimaryWls-theWl));
                
                
            case 'PIPR470noBG'
                theWl = 470;
                targetFWHM = 20;
                
                % Figure out which primary corresponds to this.
                [~, i] = max((B_primary)); wls = SToWls(S);
                thePrimaryWls = wls(i);
                [~, thePrimaryIndex] = min(abs(thePrimaryWls-theWl));
                
                
            case 'PIPR623noBG'
                theWl = 623;
                targetFWHM = 20;
                
                % Figure out which primary corresponds to this.
                [~, i] = max((B_primary)); wls = SToWls(S);
                thePrimaryWls = wls(i);
                [~, thePrimaryIndex] = min(abs(thePrimaryWls-theWl));
        end
        
        %% Generate a monochromatic spd with the properties above
        [~, monochromaticSpdPrimary] = OLSpdToPrimary(cal, OLMakeMonochromaticSpd(cal, theWl, targetFWHM), 0);
        
        % Normalize
        monochromaticSpdPrimary = monochromaticSpdPrimary/max(monochromaticSpdPrimary);
        
        % Scale to be within primary headroom
        % (1-params.primaryHeadRoom-params.bgOperatingPoint)
        monochromaticSpdPrimary = monochromaticSpdPrimary*(1-params.primaryHeadRoom-params.bgOperatingPoint);
        
        %% Obtain the retinal irradiance, with retinal filtering.
        %% Difference spd calcs.
        differenceSpd = OLPrimaryToSpd(cal, monochromaticSpdPrimary); % Already has ambient in it
        differenceSpdCorrected = differenceSpd .* LensTransmittance(S, 'Human', 'CIE', observerAgeInYears, pupilDiameterMm)';
        
        differenceRadianceWattsPerM2Sr = differenceSpdCorrected;
        differenceRadianceWattsPerM2Sr(differenceRadianceWattsPerM2Sr < 0) = 0;
        differenceRadianceWattsPerCm2Sr = (10.^-4)*differenceRadianceWattsPerM2Sr;
        differenceRadianceQuantaPerCm2SrSec = EnergyToQuanta(S,differenceRadianceWattsPerCm2Sr);
        
        %% Load CIE functions.
        load T_xyz1931
        T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
        photopicLuminanceCdM2 = T_xyz(2,:)*differenceRadianceWattsPerM2Sr;
        chromaticityXY = T_xyz(1:2,:)*differenceRadianceWattsPerM2Sr/sum(T_xyz*differenceRadianceWattsPerM2Sr);
        
        %%
        differenceDesiredPhotopicLuminanceCdM2 = photopicLuminanceCdM2; % here we set it to original one
        scaleFactor = differenceDesiredPhotopicLuminanceCdM2/photopicLuminanceCdM2;
        differenceRadianceWattsPerM2Sr = scaleFactor*differenceRadianceWattsPerM2Sr;
        differenceRadianceWattsPerCm2Sr = scaleFactor*differenceRadianceWattsPerCm2Sr;
        differenceRadianceQuantaPerCm2SrSec = scaleFactor*differenceRadianceQuantaPerCm2SrSec;
        photopicLuminanceCdM2 = scaleFactor*photopicLuminanceCdM2;
        
        %% Compute irradiance, trolands, etc.
        pupilAreaMm2 = pi*((pupilDiameterMm/2)^2);
        eyeLengthMm = 17;
        degPerMm = RetinalMMToDegrees(1,eyeLengthMm);
        differenceIrradianceWattsPerUm2 = RadianceToRetIrradiance(differenceRadianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
        differenceIrradianceScotTrolands = RetIrradianceToTrolands(differenceIrradianceWattsPerUm2, S, 'Scotopic', [], num2str(eyeLengthMm));
        differenceIrradiancePhotTrolands = RetIrradianceToTrolands(differenceIrradianceWattsPerUm2, S, 'Photopic', [], num2str(eyeLengthMm));
        differenceIrradianceQuantaPerUm2Sec = EnergyToQuanta(S,differenceIrradianceWattsPerUm2);
        differenceIrradianceWattsPerCm2 = (10.^8)*differenceIrradianceWattsPerUm2;
        differenceIrradianceQuantaPerCm2Sec = (10.^8)*differenceIrradianceQuantaPerUm2Sec;
        differenceIrradianceQuantaPerDeg2Sec = (degPerMm^2)*(10.^-2)*differenceIrradianceQuantaPerCm2Sec;
        
        % The desired retinal irradiance (with pre-receptoral filtering
        % applied) is 12.5 log quanta/cd2/sec. We scale the modulation to
        % be that.
        totalRetinalIrradianceQuataPerCm2Sec = sum(differenceIrradianceQuantaPerCm2Sec);
        desiredRetinalIrradianceQuataPerCm2Sec = 1.9953e+12; %(log 12.3)
        scaleFactor = desiredRetinalIrradianceQuataPerCm2Sec/totalRetinalIrradianceQuataPerCm2Sec;
        monochromaticSpdPrimary = scaleFactor*monochromaticSpdPrimary;
        modulationPrimary = backgroundPrimary + monochromaticSpdPrimary;
        if any(modulationPrimary >1)
        error('Primary values >1. Reduce target irradiance.')
        end
        
        %% Obtain the retinal irradiance, with retinal filtering.
        %% Difference spd calcs.
        differenceSpd = B_primary * monochromaticSpdPrimary; % Already has ambient in it
        differenceSpdCorrected = differenceSpd .* LensTransmittance(S, 'Human', 'CIE', observerAgeInYears, pupilDiameterMm)';
        
        differenceRadianceWattsPerM2Sr = differenceSpdCorrected;
        differenceRadianceWattsPerM2Sr(differenceRadianceWattsPerM2Sr < 0) = 0;
        differenceRadianceWattsPerCm2Sr = (10.^-4)*differenceRadianceWattsPerM2Sr;
        differenceRadianceQuantaPerCm2SrSec = EnergyToQuanta(S,differenceRadianceWattsPerCm2Sr);
        
        %% Load CIE functions.
        load T_xyz1931
        T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
        photopicLuminanceCdM2 = T_xyz(2,:)*differenceRadianceWattsPerM2Sr;
        chromaticityXY = T_xyz(1:2,:)*differenceRadianceWattsPerM2Sr/sum(T_xyz*differenceRadianceWattsPerM2Sr);
        
        %%
        differenceDesiredPhotopicLuminanceCdM2 = photopicLuminanceCdM2; % here we set it to original one
        scaleFactor = differenceDesiredPhotopicLuminanceCdM2/photopicLuminanceCdM2;
        differenceRadianceWattsPerM2Sr = scaleFactor*differenceRadianceWattsPerM2Sr;
        differenceRadianceWattsPerCm2Sr = scaleFactor*differenceRadianceWattsPerCm2Sr;
        differenceRadianceQuantaPerCm2SrSec = scaleFactor*differenceRadianceQuantaPerCm2SrSec;
        photopicLuminanceCdM2 = scaleFactor*photopicLuminanceCdM2;
        
        %% Compute irradiance, trolands, etc.
        pupilAreaMm2 = pi*((pupilDiameterMm/2)^2);
        eyeLengthMm = 17;
        degPerMm = RetinalMMToDegrees(1,eyeLengthMm);
        differenceIrradianceWattsPerUm2 = RadianceToRetIrradiance(differenceRadianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
        differenceIrradianceScotTrolands = RetIrradianceToTrolands(differenceIrradianceWattsPerUm2, S, 'Scotopic', [], num2str(eyeLengthMm));
        differenceIrradiancePhotTrolands = RetIrradianceToTrolands(differenceIrradianceWattsPerUm2, S, 'Photopic', [], num2str(eyeLengthMm));
        differenceIrradianceQuantaPerUm2Sec = EnergyToQuanta(S,differenceIrradianceWattsPerUm2);
        differenceIrradianceWattsPerCm2 = (10.^8)*differenceIrradianceWattsPerUm2;
        differenceIrradianceQuantaPerCm2Sec = (10.^8)*differenceIrradianceQuantaPerUm2Sec;
        differenceIrradianceQuantaPerDeg2Sec = (degPerMm^2)*(10.^-2)*differenceIrradianceQuantaPerCm2Sec;
        
        % PIPR irradiance print-out
        fprintf('> PIPR irradiance (corrected for pre-stimulus filtering:  %0.1f log10 quanta/[cm2-sec]\n',log10(sum(differenceIrradianceQuantaPerCm2Sec)));
        
        %% Background spd.  Make sure is within primaries.
        % Need to make sure we start optimization at background.
        backgroundSpd = OLPrimaryToSpd(cal, backgroundPrimary); % Already has ambient in it
        bgRadianceWattsPerM2Sr = backgroundSpd;
        bgRadianceWattsPerM2Sr(bgRadianceWattsPerM2Sr < 0) = 0;
        bgRadianceWattsPerCm2Sr = (10.^-4)*bgRadianceWattsPerM2Sr;
        bgRadianceQuantaPerCm2SrSec = EnergyToQuanta(S,bgRadianceWattsPerCm2Sr);
        
        %% Get the fraction bleached for each cone type. See
        % OLGetBGConeIsomerizations for reference.
        
        %% Load CIE functions.
        load T_xyz1931
        T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
        photopicLuminanceCdM2 = T_xyz(2,:)*bgRadianceWattsPerM2Sr;
        chromaticityXY = T_xyz(1:2,:)*bgRadianceWattsPerM2Sr/sum(T_xyz*bgRadianceWattsPerM2Sr);
        
        %% Adjust background luminance by scaling.  Handles small shifts from
        % original calibration, just by scaling.  This is close enough for purposes
        % of computing fraction of pigment bleached.
        bgDesiredPhotopicLuminanceCdM2 = photopicLuminanceCdM2; % here we set it to original one
        scaleFactor = bgDesiredPhotopicLuminanceCdM2/photopicLuminanceCdM2;
        bgRadianceWattsPerM2Sr = scaleFactor*bgRadianceWattsPerM2Sr;
        bgRadianceWattsPerCm2Sr = scaleFactor*bgRadianceWattsPerCm2Sr;
        bgRadianceQuantaPerCm2SrSec = scaleFactor*bgRadianceQuantaPerCm2SrSec;
        photopicLuminanceCdM2 = scaleFactor*photopicLuminanceCdM2;
        
        %% Get cone spectral sensitivities to use to compute isomerization rates
        lambdaMaxShift = [];
        [T_cones, T_quantalIsom]  = GetHumanPhotoreceptorSS(S, {'LCone' 'MCone' 'SCone'}, params.fieldSizeDegrees, observerAgeInYears, pupilDiameterMm, [], []);
        [T_conesHemo, T_quantalIsomHemo]  = GetHumanPhotoreceptorSS(S, {'LConeHemo' 'MConeHemo' 'SConeHemo'}, params.fieldSizeDegrees, observerAgeInYears, pupilDiameterMm, [], []);
        
        %% Compute irradiance, trolands, etc.
        pupilAreaMm2 = pi*((pupilDiameterMm/2)^2);
        eyeLengthMm = 17;
        degPerMm = RetinalMMToDegrees(1,eyeLengthMm);
        bgIrradianceWattsPerUm2 = RadianceToRetIrradiance(bgRadianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
        bgIrradianceScotTrolands = RetIrradianceToTrolands(bgIrradianceWattsPerUm2, S, 'Scotopic', [], num2str(eyeLengthMm));
        bgIrradiancePhotTrolands = RetIrradianceToTrolands(bgIrradianceWattsPerUm2, S, 'Photopic', [], num2str(eyeLengthMm));
        bgIrradianceQuantaPerUm2Sec = EnergyToQuanta(S,bgIrradianceWattsPerUm2);
        bgIrradianceWattsPerCm2 = (10.^8)*bgIrradianceWattsPerUm2;
        bgIrradianceQuantaPerCm2Sec = (10.^8)*bgIrradianceQuantaPerUm2Sec;
        bgIrradianceQuantaPerDeg2Sec = (degPerMm^2)*(10.^-2)*bgIrradianceQuantaPerCm2Sec;
        
        %% This is just to get cone inner segment diameter
        photoreceptors = DefaultPhotoreceptors('CIE10Deg');
        photoreceptors = FillInPhotoreceptors(photoreceptors);
        
        %% Get isomerizations
        theLMSIsomerizations = PhotonAbsorptionRate(bgIrradianceQuantaPerUm2Sec,S, ...
            T_quantalIsom,S,photoreceptors.ISdiameter.value);
        theLMSIsomerizationsHemo = PhotonAbsorptionRate(bgIrradianceQuantaPerUm2Sec,S, ...
            T_quantalIsomHemo,S,photoreceptors.ISdiameter.value);
        
        %% Get fraction bleached
        fractionBleachedFromTrolands = ComputePhotopigmentBleaching(bgIrradiancePhotTrolands,'cones','trolands','Boynton');
        fractionBleachedFromIsom = zeros(3,1);
        fractionBleachedFromIsomHemo = zeros(3,1);
        for i = 1:3
            fractionBleachedFromIsom(i) = ComputePhotopigmentBleaching(theLMSIsomerizations(i),'cones','isomerizations','Boynton');
            fractionBleachedFromIsomHemo(i) = ComputePhotopigmentBleaching(theLMSIsomerizationsHemo(i),'cones','isomerizations','Boynton');
        end
        fprintf('    * Stimulus luminance %0.1f candelas/m2\n',photopicLuminanceCdM2);
        fprintf('    * Fraction bleached computed from trolands (applies to L and M cones): %0.2f\n',fractionBleachedFromTrolands);
        fprintf('    * Fraction bleached from isomerization rates: L, %0.2f; M, %0.2f; S, %0.2f\n', ...
            fractionBleachedFromIsom(1),fractionBleachedFromIsom(2),fractionBleachedFromIsom(3));
        fprintf('    * Fraction bleached from isomerization rates: LHemo, %0.2f; MHemo, %0.2f; SHemo, %0.2f\n', ...
            fractionBleachedFromIsomHemo(1),fractionBleachedFromIsomHemo(2),fractionBleachedFromIsomHemo(3));
        
        % We can now assign the fraction bleached for each photoreceptor
        % class.
        for p = 1:length(photoreceptorClasses)
            switch photoreceptorClasses{p}
                case 'LCone'
                    fractionBleached(p) = fractionBleachedFromIsom(1);
                case 'MCone'
                    fractionBleached(p) = fractionBleachedFromIsom(2);
                case 'SCone'
                    fractionBleached(p) = fractionBleachedFromIsom(3);
                case 'LConeHemo'
                    fractionBleached(p) = fractionBleachedFromIsomHemo(1);
                case 'MConeHemo'
                    fractionBleached(p) = fractionBleachedFromIsomHemo(2);
                case 'SConeHemo'
                    fractionBleached(p) = fractionBleachedFromIsomHemo(3);
                otherwise
                    fractionBleached(p) = 0;
            end
        end
        
        % If the cache file name contains 'ScreeningUncorrected', assume no
        % bleaching
        if strfind(cacheFileName, 'ScreeningUncorrected')
            fractionBleached(:) = 0;
        end
        
        % Construct the receptor matrix
        T_receptors = GetHumanPhotoreceptorSS(S, photoreceptorClasses, params.fieldSizeDegrees, observerAgeInYears, pupilDiameterMm, [], fractionBleached);
        
        % Calculate the receptor activations to the background
        backgroundReceptors = T_receptors*(B_primary*backgroundPrimary + ambientSpd);
        
        % If the config contains a field called Klein check, get the Klein
        % XYZ also
        if isfield(params, 'checkKlein') && params.checkKlein;
            T_klein = GetKleinK10AColorimeterXYZ(S);
            T_receptors = [T_receptors ; T_klein];
            photoreceptorClasses = [photoreceptorClasses kleinLabel];
        end
        
        %% Modulation spd calcs.
        modulationSpd = OLPrimaryToSpd(cal, modulationPrimary); % Already has ambient in it
        modulationRadianceWattsPerM2Sr = modulationSpd;
        modulationRadianceWattsPerM2Sr(modulationRadianceWattsPerM2Sr < 0) = 0;
        modulationRadianceWattsPerCm2Sr = (10.^-4)*modulationRadianceWattsPerM2Sr;
        modulationRadianceQuantaPerCm2SrSec = EnergyToQuanta(S,modulationRadianceWattsPerCm2Sr);
        
        %% Load CIE functions.
        load T_xyz1931
        T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
        photopicLuminanceCdM2 = T_xyz(2,:)*modulationRadianceWattsPerM2Sr;
        chromaticityXY = T_xyz(1:2,:)*modulationRadianceWattsPerM2Sr/sum(T_xyz*modulationRadianceWattsPerM2Sr);
        
        modulationDesiredPhotopicLuminanceCdM2 = photopicLuminanceCdM2; % here we set it to original one
        scaleFactor = modulationDesiredPhotopicLuminanceCdM2/photopicLuminanceCdM2;
        modulationRadianceWattsPerM2Sr = scaleFactor*modulationRadianceWattsPerM2Sr;
        modulationRadianceWattsPerCm2Sr = scaleFactor*modulationRadianceWattsPerCm2Sr;
        modulationRadianceQuantaPerCm2SrSec = scaleFactor*modulationRadianceQuantaPerCm2SrSec;
        photopicLuminanceCdM2 = scaleFactor*photopicLuminanceCdM2;
        
        %% Compute irradiance, trolands, etc.
        pupilAreaMm2 = pi*((pupilDiameterMm/2)^2);
        eyeLengthMm = 17;
        degPerMm = RetinalMMToDegrees(1,eyeLengthMm);
        modulationIrradianceWattsPerUm2 = RadianceToRetIrradiance(modulationRadianceWattsPerM2Sr,S,pupilAreaMm2,eyeLengthMm);
        modulationIrradianceScotTrolands = RetIrradianceToTrolands(modulationIrradianceWattsPerUm2, S, 'Scotopic', [], num2str(eyeLengthMm));
        modulationIrradiancePhotTrolands = RetIrradianceToTrolands(modulationIrradianceWattsPerUm2, S, 'Photopic', [], num2str(eyeLengthMm));
        modulationIrradianceQuantaPerUm2Sec = EnergyToQuanta(S,modulationIrradianceWattsPerUm2);
        modulationIrradianceWattsPerCm2 = (10.^8)*modulationIrradianceWattsPerUm2;
        modulationIrradianceQuantaPerCm2Sec = (10.^8)*modulationIrradianceQuantaPerUm2Sec;
        modulationIrradianceQuantaPerDeg2Sec = (degPerMm^2)*(10.^-2)*modulationIrradianceQuantaPerCm2Sec;
        
        
        %% Look at both negative and positive swing
        differencePrimary = modulationPrimary - backgroundPrimary;
        modulationPrimarySignedPositive = backgroundPrimary+differencePrimary;
        modulationPrimarySignedNegative = backgroundPrimary-differencePrimary;
        
        %% Compute and report constrasts
        differenceSpdSignedPositive = B_primary*(modulationPrimarySignedPositive-backgroundPrimary);
        differenceReceptors = T_receptors*differenceSpdSignedPositive;
        isolateContrastsSignedPositive = differenceReceptors ./ backgroundReceptors;
        
        differenceSpdSignedNegative = B_primary*(modulationPrimarySignedNegative-backgroundPrimary);
        differenceReceptors = T_receptors*differenceSpdSignedNegative;
        isolateContrastsSignedNegative = differenceReceptors ./ backgroundReceptors;
        
        fprintf('\n> Observer age: %g\n',observerAgeInYears);
        for j = 1:size(T_receptors,1)
            fprintf('  - %s: contrast = \t%f / %f\n',photoreceptorClasses{j},isolateContrastsSignedPositive(j),isolateContrastsSignedNegative(j));
        end
        
        % Assign all the cache fields
        
        %% Save out important information
        cacheData.data(observerAgeInYears).describe.params = params;                     % Parameters
        cacheData.data(observerAgeInYears).describe.B_primary = B_primary;
        cacheData.data(observerAgeInYears).describe.photoreceptors = photoreceptorClasses;     % Photoreceptors
        cacheData.data(observerAgeInYears).describe.fractionBleached = fractionBleached;
        cacheData.data(observerAgeInYears).describe.S = S;     % Photoreceptors
        cacheData.data(observerAgeInYears).describe.T_receptors = T_receptors;
        cacheData.data(observerAgeInYears).describe.S_receptors = S;
        cacheData.data(observerAgeInYears).describe.params.maxPowerDiff = params.maxPowerDiff;
        cacheData.data(observerAgeInYears).describe.params.primaryHeadRoom = params.primaryHeadRoom;
        cacheData.data(observerAgeInYears).describe.contrast = isolateContrastsSignedPositive;
        cacheData.data(observerAgeInYears).describe.contrastSignedPositive = isolateContrastsSignedPositive;
        cacheData.data(observerAgeInYears).describe.contrastSignedNegative = isolateContrastsSignedNegative;
        cacheData.data(observerAgeInYears).describe.bgOperatingPoint = params.bgOperatingPoint;
        cacheData.cal = cal;
        
        %% Stick in there the stuff we've calculated
        % Background
        cacheData.data(observerAgeInYears).backgroundPrimary = backgroundPrimary;
        cacheData.data(observerAgeInYears).backgroundSpd = backgroundSpd;
        
        % Modulation (unsigned)
        cacheData.data(observerAgeInYears).differencePrimary = differencePrimary;
        cacheData.data(observerAgeInYears).differenceSpd = B_primary*differencePrimary;
        
        % Modulation (signed)
        cacheData.data(observerAgeInYears).modulationPrimarySignedPositive = modulationPrimarySignedPositive;
        cacheData.data(observerAgeInYears).modulationPrimarySignedNegative = modulationPrimarySignedNegative;
        cacheData.data(observerAgeInYears).modulationSpdSignedPositive = (B_primary*modulationPrimarySignedPositive) + ambientSpd;
        cacheData.data(observerAgeInYears).modulationSpdSignedNegative = (B_primary*modulationPrimarySignedNegative) + ambientSpd;
        
        cacheData.data(observerAgeInYears).ambientSpd = ambientSpd;
        cacheData.data(observerAgeInYears).operatingPoint = operatingPoint;
        
        % Include the compute method
        cacheData.data(observerAgeInYears).computeMethod = OLComputeMethods.ReceptorIsolate;
        cacheData.computeMethod = char(OLComputeMethods.ReceptorIsolate);
        
    end
    
    contrastVector = cacheData.data(params.REFERENCE_OBSERVER_AGE).describe.contrast;
    
    % Calculate the spaltter
    [calID calIDTitle] = OLGetCalID(cal);
    
    if params.CALCULATE_SPLATTER
        fprintf('> Requested to calculate splatter as per params.CALCULATE_SPLATTER flag...\n');
        
        % Pull out the data for the reference observer
        data = cacheData.data(params.REFERENCE_OBSERVER_AGE);
        
        %% Make plot of spectra and save as csv
        theSpectraFig = figure;
        subplot(1, 4, 1);
        plot(SToWls(S), data.backgroundSpd);
        xlim([380 780]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('Background'); pbaspect([1 1 1]);
        
        subplot(1, 4, 2);
        plot(SToWls(S), data.modulationSpdSignedPositive); hold on;
        plot(SToWls(S), data.backgroundSpd, '--k');
        xlim([380 780]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('+ve modulation'); pbaspect([1 1 1]);
        
        subplot(1, 4, 4);
        plot(SToWls(S), data.modulationSpdSignedPositive-data.backgroundSpd, '-r'); hold on;
        xlim([380 780]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('Difference spectra'); pbaspect([1 1 1]);
        
        % Save plots
        suptitle(sprintf('%s\n%s', calIDTitle, cacheFileName));
        set(theSpectraFig, 'PaperPosition', [0 0 20 10]);
        set(theSpectraFig, 'PaperSize', [20 10]);
        
        currDir = pwd;
        cd(docDir);
        saveas(theSpectraFig, ['Spectra_' calID], 'pdf');
        cd(currDir);
        
        % Save as CSV
        csvwrite(fullfile(docDir, ['Spectra_' calID '.csv']), [SToWls(S) data.backgroundSpd data.modulationSpdSignedPositive data.modulationSpdSignedNegative]);
        
%         % Only do the splatter calcs if the Klein is not involved
%         if ~(isfield(params, 'checkKlein') && params.checkKlein);
%             theCanonicalPhotoreceptors = {'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods'};
%             %% Plot both the positive and the negative lobes.
%             
%             %% Positive modulation
%             for k = 1:length(theCanonicalPhotoreceptors)
%                 targetContrasts{k} = data.describe.contrastSignedPositive(k);
%             end
%             backgroundSpd = data.backgroundSpd;
%             modulationSpd = data.modulationSpdSignedPositive;
%             fileNameSuffix = '_positive';
%             titleSuffix = 'Positive';
%             
%             % Calculate the splatter
%             lambdaMaxRange = [];
%             ageRange = [];
%             [contrastMap, nominalLambdaMax, ageRange, lambdaMaxShiftRange] = CalculateSplatter(S, backgroundSpd, modulationSpd, theCanonicalPhotoreceptors, data.describe.params.fieldSizeDegrees, params.REFERENCE_OBSERVER_AGE, [], pupilDiameterMm, [], cacheData.data(params.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
%             
%             % Plot the splatter
%             SAVEPLOTS = 0;
%             theFig = PlotSplatter(figure, contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts, [], 1, 2, SAVEPLOTS, titleSuffix, [], 32);
%             % Save out the splatter
%             SaveSplatter(docDir, [fileNameSuffix '_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts);
%             SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_95CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9545);
%             SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_99CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9973);
%             %% Negative modulation
%             for k = 1:length(theCanonicalPhotoreceptors)
%                 targetContrasts{k} = data.describe.contrastSignedNegative(k);
%             end
%             backgroundSpd = data.backgroundSpd;
%             modulationSpd = data.modulationSpdSignedNegative;
%             fileNameSuffix = '_negative';
%             titleSuffix = 'Negative';
%             
%             % Calculate the splatter
%             lambdaMaxRange = [];
%             ageRange = [];
%             [contrastMap, nominalLambdaMax, ageRange, lambdaMaxShiftRange] = CalculateSplatter(S, backgroundSpd, modulationSpd, theCanonicalPhotoreceptors, data.describe.params.fieldSizeDegrees, params.REFERENCE_OBSERVER_AGE, ageRange, pupilDiameterMm, [], cacheData.data(params.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
%             
%             % Plot the splatter
%             theFig = PlotSplatter(figure, contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts, [], 1, 2, SAVEPLOTS, titleSuffix, [], 32);
%             
%             % Add a suplabel
%             figure(theFig);
%             suplabel(sprintf('%s/%s', calIDTitle, cacheFileName));
%             
%             %% Save plots
%             set(theFig, 'Color', [1 1 1]);
%             set(theFig, 'InvertHardCopy', 'off');
%             set(theFig, 'PaperPosition', [0 0 20 12]); %Position plot at left hand corner with width 15 and height 6.
%             set(theFig, 'PaperSize', [20 12]); %Set the paper to have width 15 and height 6.
%             saveas(theFig, fullfile(docDir, ['Splatter_' calID]), 'pdf');
%             
%             fprintf('  - Contrast plot saved to %s.\n', fullfile(docDir, ['Splatter_' calID]));
%             
%             % Save out the splatter
%             SaveSplatter(docDir, [fileNameSuffix '_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts);
%             SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_95CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9545);
%             SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_99CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9973);
%        end
    end
end
end

function contrast = ComputeContrastIso(T_receptors, B_primary, backgroundPrimary, ambientSpd, desiredContrast, c)
backgroundReceptors = T_receptors*(B_primary*backgroundPrimary + ambientSpd);
backgroundSpd = B_primary*backgroundPrimary + ambientSpd;
modulationPrimary = backgroundPrimary+backgroundPrimary*desiredContrast+c;


%% Look at both negative and positive swing
differencePrimary = modulationPrimary - backgroundPrimary;
modulationPrimarySignedPositive = backgroundPrimary+differencePrimary;
modulationPrimarySignedNegative = backgroundPrimary-differencePrimary;

%% Compute and report constrasts
differenceSpdSignedPositive = B_primary*(modulationPrimarySignedPositive-backgroundPrimary);
differenceReceptors = T_receptors*differenceSpdSignedPositive;
contrast = differenceReceptors ./ backgroundReceptors;

end

function error = FitIsoScalar(c, T_receptors, B_primary, backgroundPrimary, ambientSpd, desiredContrast);
contrast = mean(ComputeContrastIso(T_receptors, B_primary, backgroundPrimary, ambientSpd, desiredContrast, c));
error = sqrt(sum(contrast-desiredContrast).^2);
end