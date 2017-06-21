function OLAnalyzeCacheReceptorIsolate(cacheFileName, selectedCalType, params, S_filter, T_filter, filterName)
% OLAnalyzeCacheReceptorIsolate(cacheName, filter, filterName)
%
% Calculates splatter in a cache file, with option to incorporate a filter.

S = [380 2 201];
pupilDiameterMm = 3;

if isempty(S_filter)
    S_filter = S;
else
    if any(S_filter ~= [380 2 201])
        error('S vector not standard');
    end
end

if isempty(T_filter)
    T_filter = ones(S_filter(3), 1);
end


if isempty(filterName)
    filterSuffix = '';
else
    filterSuffix = ['_' filterName];
end

% Deduce the cache directory.
[cacheDir, simpleCacheFileName] = fileparts(cacheFileName);
% Load the cache file.
data = load(cacheFileName);
assert(isstruct(data), 'OLValidateCacheFile:InvalidCacheFile', ...
    'Specified file doesn''t seem to be a cache file: %s', cacheFileName);

% List the available calibration types found in the cache file.
foundCalTypes = sort(fieldnames(data));

% Make sure the all the calibration types loaded seem legit. We want to
% make sure that we have at least one calibration type which we know of.
% Otherwise, we abort.
[~, validCalTypes] = enumeration('OLCalibrationTypes');
for i = 1:length(foundCalTypes)
    typeExists(i) = any(strcmp(foundCalTypes{i}, validCalTypes));
end
assert(any(typeExists), 'OLValidateCacheFile:InvalidCacheFile', ...
    'File contains does not contain at least one valid calibration type');

% Display a list of all the calibration types contained in the file and
% have the user select one to validate.
while true
    fprintf('\n- Calibration Types in Cache File (*** = valid)\n\n');
    
    for i = 1:length(foundCalTypes)
        if typeExists(i)
            typeState = '***';
        else
            typeState = '---';
        end
        fprintf('%i (%s): %s\n', i, typeState, foundCalTypes{i});
    end
    fprintf('\n');
    
    % Check if 'selectedCalType' was passed.
    if exist('selectedCalType', 'var') && any(strcmp(foundCalTypes{i}, validCalTypes))
        break;
    end
    
    t = GetInput('Select a Number', 'number', 1);
    
    if t >= 1 && t <= length(foundCalTypes) && typeExists(t);
        fprintf('\n');
        selectedCalType = foundCalTypes{t};
        break;
    else
        fprintf('\n*** Invalid selection try again***\n\n');
    end
end

% Load the calibration file associated with this calibration type.
cal = LoadCalFile(OLCalibrationTypes.(selectedCalType).CalFileName)
[calID calIDTitle] = OLGetCalID(cal);

%% Set up camp
if length(filterName) > 0
    docDir = fullfile(cacheDir, simpleCacheFileName, char(cal.describe.calType), strrep(strrep(cal.describe.date, ' ', '_'), ':', '_'), filterName);
else
    docDir = fullfile(cacheDir, simpleCacheFileName, char(cal.describe.calType), strrep(strrep(cal.describe.date, ' ', '_'), ':', '_'));
end
if ~exist(docDir)
    mkdir(docDir);
end

% Setup the OLCache object.
olCache = OLCache(cacheDir, cal);

% Load the calibration data.  We do it through the cache object so that we
% make sure that the cache is current against the latest calibration data.
[cacheData, wasRecomputed] = olCache.load(simpleCacheFileName);

% Pull out the data for the reference observer
data = cacheData.data(params.REFERENCE_OBSERVER_AGE);

%% Make plot of spectra and save as csv
theSpectraFig = figure;
subplot(1, 3, 1);
plot(SToWls(S), data.backgroundSpd .* T_filter);
xlim([380 780]);
xlabel('Wavelength [nm]'); ylabel('Power'); title('Background'); pbaspect([1 1 1]);

subplot(1, 3, 2);
plot(SToWls(S), data.modulationSpdSignedPositive .* T_filter); hold on;
plot(SToWls(S), data.backgroundSpd .* T_filter, '--k');
xlim([380 780]);
xlabel('Wavelength [nm]'); ylabel('Power'); title('+ve modulation'); pbaspect([1 1 1]);

subplot(1, 3, 3);
plot(SToWls(S), data.modulationSpdSignedNegative .* T_filter); hold on;
plot(SToWls(S), data.backgroundSpd .* T_filter, '--k');
xlim([380 780]);
xlabel('Wavelength [nm]'); ylabel('Power'); title('-ve modulation'); pbaspect([1 1 1]);

% Save plots
suptitle(sprintf('%s\n%s', calIDTitle, simpleCacheFileName));
set(theSpectraFig, 'PaperPosition', [0 0 20 10]);
set(theSpectraFig, 'PaperSize', [20 10]);
currDir = pwd;
cd(docDir);
saveas(theSpectraFig, ['Spectra_' calID], 'pdf');
cd(currDir);

% Save as CSV
csvwrite(fullfile(docDir, ['Spectra_' calID '.csv']), [SToWls(S) data.backgroundSpd data.modulationSpdSignedPositive data.modulationSpdSignedNegative]);

% Only do the splatter calcs if the Klein is not involved
if ~(isfield(params, 'checkKlein') && params.checkKlein);
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
        
        subplot(1, 4, 3);
        plot(SToWls(S), data.modulationSpdSignedNegative); hold on;
        plot(SToWls(S), data.backgroundSpd, '--k');
        xlim([380 780]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('-ve modulation'); pbaspect([1 1 1]);
        
        subplot(1, 4, 4);
        plot(SToWls(S), data.modulationSpdSignedPositive-data.backgroundSpd, '-r'); hold on;
        plot(SToWls(S), data.modulationSpdSignedNegative-data.backgroundSpd, '-b'); hold on;
        xlim([380 780]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('Difference spectra'); pbaspect([1 1 1]);
        
        % Save plots
        suptitle(sprintf('%s\n%s', calIDTitle, cacheFileName));
        set(theSpectraFig, 'PaperPosition', [0 0 20 10]);
        set(theSpectraFig, 'PaperSize', [20 10]);
        
        currDir = pwd;
        
        cd(docDir);
        saveas(theSpectraFig, ['Spectra_' calID], 'pdf');
        cd(currDir)
        
        % Save as CSV
        csvwrite(fullfile(docDir, ['Spectra_' calID '.csv']), [SToWls(S) data.backgroundSpd data.modulationSpdSignedPositive data.modulationSpdSignedNegative]);
        
        % Only do the splatter calcs if the Klein is not involved
        if ~(isfield(params, 'checkKlein') && params.checkKlein);
            theCanonicalPhotoreceptors = {'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods', 'LConeHemo', 'MConeHemo', 'SConeHemo'};
            %% Plot both the positive and the negative lobes.
            
            %% Positive modulation
            for k = 1:length(theCanonicalPhotoreceptors)
                targetContrasts{k} = data.describe.contrastSignedPositive(k);
            end
            backgroundSpd = data.backgroundSpd;
            modulationSpd = data.modulationSpdSignedPositive;
            fileNameSuffix = '_positive';
            titleSuffix = 'Positive';
            
            % Calculate the splatter
            lambdaMaxRange = [];
            ageRange = [];
            [contrastMap, nominalLambdaMax, ageRange, lambdaMaxShiftRange] = CalculateSplatter(S, backgroundSpd, modulationSpd, theCanonicalPhotoreceptors, data.describe.params.fieldSizeDegrees, [], pupilDiameterMm, [], cacheData.data(params.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
            
            % Plot the splatter
            SAVEPLOTS = 0;
            theFig = PlotSplatter(figure, contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts, [], 1, 2, SAVEPLOTS, titleSuffix, [], 27);
            % Save out the splatter
            SaveSplatter(docDir, [fileNameSuffix '_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts);
            SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_95CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9545);
            SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_99CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9973);
            
            
            %% Negative modulation
            for k = 1:length(theCanonicalPhotoreceptors)
                targetContrasts{k} = data.describe.contrastSignedNegative(k);
            end
            backgroundSpd = data.backgroundSpd;
            modulationSpd = data.modulationSpdSignedNegative;
            fileNameSuffix = '_negative';
            titleSuffix = 'Negative';
            
            % Calculate the splatter
            lambdaMaxRange = [];
            ageRange = [];
            [contrastMap, nominalLambdaMax, ageRange, lambdaMaxShiftRange] = CalculateSplatter(S, backgroundSpd, modulationSpd, theCanonicalPhotoreceptors, data.describe.params.fieldSizeDegrees, ageRange, pupilDiameterMm, [], cacheData.data(params.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
            
            % Plot the splatter
            theFig = PlotSplatter(theFig, contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts, [], 2, 2, SAVEPLOTS, titleSuffix, [], 27);
            
            % Add a suplabel
            figure(theFig);
            suplabel(sprintf('%s/%s', calIDTitle, cacheFileName));
            
            %% Save plots
            set(theFig, 'Color', [1 1 1]);
            set(theFig, 'InvertHardCopy', 'off');
            set(theFig, 'PaperPosition', [0 0 20 12]); %Position plot at left hand corner with width 15 and height 6.
            set(theFig, 'PaperSize', [20 12]); %Set the paper to have width 15 and height 6.
            currDir = pwd;
            cd(docDir);
            saveas(theFig, ['Splatter_' calID], 'pdf');
            cd(currDir);
            
            fprintf('  - Contrast plot saved to %s.\n', fullfile(docDir, ['Splatter_' calID]));
            
            % Save out the splatter
            SaveSplatter(docDir, [fileNameSuffix '_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, params.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts);
            SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_95CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9545);
            SaveSplatterConfidenceBounds(docDir, [fileNameSuffix '_99CI_' calID], contrastMap, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9973);
            
        end
    end
end