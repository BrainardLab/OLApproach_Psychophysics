function OLReceptorIsolateCheckAllValidations(basePath, theDirection, theCalType, theCalDate)
%% Set up standard values
S = [380 2 201];
wls = SToWls(S);

%% Check what validations are there.
theValPath = fullfile(basePath, ['Cache-' theDirection], theCalType, theCalDate, 'validation');
folders = dir(theValPath);

% Only take the folders
folders = folders([folders.isdir]);
folders = folders(arrayfun(@(x) x.name(1), folders) ~= '.');

% Find out how many validations we have
nValidations = length(folders);

%% Iterate over the validations
theValName = ['Cache-' theDirection '-' theCalType '-SpotCheck.mat'];
for i = 1:nValidations
    load(fullfile(theValPath, folders(i).name, theValName));
    theBGSpectra(:, i) = cals{end}.modulationBGMeas.meas.pr650.spectrum';
    theMaxSpectra(:, i) = cals{end}.modulationMaxMeas.meas.pr650.spectrum';
    theMinSpectra(:, i) = cals{end}.modulationMinMeas.meas.pr650.spectrum';
    
    % Get the predicted spd
    theBGSpectraPredicted(:, i) = cals{end}.modulationBGMeas.predictedSpd;
    theMaxSpectraPredicted(:, i) = cals{end}.modulationMaxMeas.predictedSpd;
    theMinSpectraPredicted(:, i) = cals{end}.modulationMinMeas.predictedSpd;
    
    % Scale by first predicted spectrum (as reference)
    theWeight(:, i) = theBGSpectra(:, i) \ theBGSpectraPredicted(:, 1);
    theBGSpectraScaled(:, i) = theBGSpectra(:, i)*theWeight(:, i);
    theMaxSpectraScaled(:, i) = theMaxSpectra(:, i)*theWeight(:, i);
    theMinSpectraScaled(:, i) = theMinSpectra(:, i)*theWeight(:, i);
end

% Figure out the y scale

yLimVal = max(max(theBGSpectraPredicted))*1.5;

%% Plot in figure
theFig = figure;

subplot(2, 3, 1); % Background
H1 = shadedErrorBar(wls,mean(theBGSpectraScaled, 2),3*std(theBGSpectraScaled, [], 2)/sqrt(nValidations), '-k'); hold on;
H2 = plot(wls, theBGSpectraPredicted(:, 1), '-r');
pbaspect([1 1 1]); ylim([0 yLimVal]); xlim([min(wls) max(wls)]);
xlabel('Wavelength [nm]');
ylabel('Power');
title('Background');
legend([H1.mainLine H2], 'Measured (mean, ±3 SEM)', 'Predicted'); legend boxoff;

subplot(2, 3, 2); % Positive
shadedErrorBar(wls,mean(theMaxSpectraScaled-theBGSpectraScaled, 2),3*std(theMaxSpectraScaled-theBGSpectraScaled, [], 2)/sqrt(nValidations), '-k'); hold on;
plot(wls, theMaxSpectraPredicted(:, 1)-theBGSpectraPredicted(:, 1), '-r');
pbaspect([1 1 1]); ylim([-yLimVal yLimVal]); xlim([min(wls) max(wls)]);
xlabel('Wavelength [nm]');
ylabel('Power');
title('Difference spectrum (positive)');

subplot(2, 3, 3); % Negative
shadedErrorBar(wls,mean(theMinSpectraScaled-theBGSpectraScaled, 2),3*std(theMinSpectraScaled-theBGSpectraScaled, [], 2)/sqrt(nValidations), '-k'); hold on;
plot(wls, theMinSpectraPredicted(:, 1)-theBGSpectraPredicted(:, 1), '-r');
pbaspect([1 1 1]); ylim([-yLimVal yLimVal]); xlim([min(wls) max(wls)]);
xlabel('Wavelength [nm]');
ylabel('Power');
title('Difference spectrum (negative)');

%% Add the splatter
% Get the splatter statistics from a file that's generated when the
% validations are splatter-validated.
for i = 1:nValidations
    theFile = dir(fullfile(theValPath, folders(i).name, 'Splatter_statistics_positive*'));
    if ~isempty(theFile)
        splatterPos(:, i) = csvread(fullfile(theValPath, folders(i).name, theFile.name),1,7,[1 7 5 7]); % Only pull out the relevant pieces
        splatterPosTarget(:, i) = csvread(fullfile(theValPath, folders(i).name, theFile.name),1,6,[1 6 5 6]); % Only pull out the relevant pieces
    end
    
    theFile = dir(fullfile(theValPath, folders(i).name, 'Splatter_statistics_negative*'));
    if ~isempty(theFile)
        splatterNeg(:, i) = csvread(fullfile(theValPath, folders(i).name, theFile.name),1,7,[1 7 5 7]); % Only pull out the relevant pieces
        splatterNegTarget(:, i) = csvread(fullfile(theValPath, folders(i).name, theFile.name),1,6,[1 6 5 6]); % Only pull out the relevant pieces
        
        % Extract the receptor labels
        fid = fopen(fullfile(theValPath, folders(i).name, theFile.name));
        theLabels = textscan(fid,'%s%f%f%f%f%f%f%f%f%f%f%f', 'delimiter', ',', 'HeaderLines', 1);
        fclose(fid);
    end
end

% Get number of receptors for which we have splatter calculations.
theLabels = theLabels{1};
nReceptors = length(theLabels);

%% Plot the splatter
subplot(2, 3, 5);
colormap(gray);
bar(splatterPos); hold on;
% Plot reference lines
for i = 1:nReceptors
    a = plot(i, splatterPosTarget(i, 1), 'sr', 'MarkerFaceColor', 'r');
end
xlim([0 nReceptors+1]); ylim([-0.5 0.5]);
set(gca, 'XTick', 1:nReceptors, 'XTickLabel', theLabels)
pbaspect([1 1 1]);

subplot(2, 3, 6);
colormap(gray);
bar(splatterNeg); hold on;
% Plot reference lines
for i = 1:nReceptors
    a = plot(i, splatterNegTarget(i, 1), 'sr', 'MarkerFaceColor', 'r');
end
xlim([0 nReceptors+1]); ylim([-0.5 0.5]);
set(gca, 'XTick', 1:nReceptors, 'XTickLabel', theLabels)
pbaspect([1 1 1]);
legend(a, 'Target contrast'); legend boxoff;

%% Save plots
set(theFig, 'Color', [1 1 1]);
set(theFig, 'InvertHardCopy', 'off');
set(theFig, 'PaperPosition', [0 0 20 10]); %Position plot at left hand corner with width 15 and height 6.
set(theFig, 'PaperSize', [20 10]); %Set the paper to have width 15 and height 6.
saveas(theFig, fullfile(theValPath, 'AllValidations.pdf'), 'pdf')

%% Get luminance and chromaticity
% Get CIE 1931
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);

% Background
theBGSpectra_photopicLuminanceCdM2 = T_xyz(2,:)*theBGSpectra;
theBGSpectra_chromaticityXY = T_xyz(1:2,:)*theBGSpectra./repmat(sum(T_xyz*theBGSpectra), 2, 1);

% Plot luminance
theLumFig = figure;
boxplot(theBGSpectra_photopicLuminanceCdM2', 'orientation', 'horizontal', 'labels', 'Background');
xlabel('Luminance [cd/m2]');
xlim([min(theBGSpectra_photopicLuminanceCdM2)-0.05*mean(max(theBGSpectra_photopicLuminanceCdM2)) max(theBGSpectra_photopicLuminanceCdM2)+0.05*mean(max(theBGSpectra_photopicLuminanceCdM2))]);
pbaspect([1 0.2 1]);
title('Luminance');

%% Save plots
set(theLumFig, 'Color', [1 1 1]);
set(theLumFig, 'InvertHardCopy', 'off');
set(theLumFig, 'PaperPosition', [0 0 5 2]); %Position plot at left hand corner with width 15 and height 6.
set(theLumFig, 'PaperSize', [5 2]); %Set the paper to have width 15 and height 6.
saveas(theLumFig, fullfile(theValPath, 'AllValidations_BackgroundLuminance.pdf'), 'pdf')

% Plot chromaticity in horse shoe diagram
theChromFig = figure;
plot(mean(theBGSpectra_chromaticityXY(1, :)), mean(theBGSpectra_chromaticityXY(2, :)), 'x'); hold on;
covMatrix = cov(theBGSpectra_chromaticityXY(1, :), theBGSpectra_chromaticityXY(2, :));
error_ellipse(covMatrix, [mean(theBGSpectra_chromaticityXY(1, :)) mean(theBGSpectra_chromaticityXY(2, :))], 'conf', 0.95);

% Plot E-E white
plot(0.33, 0.33, 'sk', 'MarkerFaceColor', 'w');

% Plot horseshoe diagram for reference
load T_xyz1931
out = SplineCmf(S_xyz1931, T_xyz1931, S_xyz1931);
x = out(1, :)./sum(out);
y = out(2, :)./sum(out);
plot([x(1:65) x(1)], [y(1:65) y(1)], '--k');
pbaspect([1 1 1]);
xlim([-0.05 0.8]); ylim([-0.05 0.9]);
xlabel('x');
ylabel('y');
title('Stimulus chromaticity');

%% Save plots
set(theChromFig, 'Color', [1 1 1]);
set(theChromFig, 'InvertHardCopy', 'off');
set(theChromFig, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 15 and height 6.
set(theChromFig, 'PaperSize', [5 5]); %Set the paper to have width 15 and height 6.
saveas(theChromFig, fullfile(theValPath, 'AllValidations_BackgroundChromaticity.pdf'), 'pdf')

% Save out chromaticity, etc.
fid = fopen(fullfile(theValPath, 'AllValidations.csv'), 'w');
fprintf(fid, 'Date,Luminance [cd/m2],x chromaticity (CIE 1931),y chromaticity (CIE 1931)\n');
for i = 1:nValidations
    fprintf(fid, '%s,%f,%f,%f\n', folders(i).name, theBGSpectra_photopicLuminanceCdM2(i), theBGSpectra_chromaticityXY(1, i), theBGSpectra_chromaticityXY(2, i));
end
fprintf(fid, '%s,%f,%f,%f\n', 'Mean', mean(theBGSpectra_photopicLuminanceCdM2), mean(theBGSpectra_chromaticityXY(1, :)), mean(theBGSpectra_chromaticityXY(2, :)));
fprintf(fid, '%s,%f,%f,%f\n', 'SD', std(theBGSpectra_photopicLuminanceCdM2), std(theBGSpectra_chromaticityXY(1, :)), std(theBGSpectra_chromaticityXY(2, :)));
fclose(fid);