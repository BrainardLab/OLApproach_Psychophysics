%% Which validations set?
validations = validationsPre;

%% Get mel pair validations
validations_mel_high = validations('Mel_high');
validations_mel_low = validations('Mel_low');

%% Get luminances
luminances_mel_high = vertcat(validations_mel_high.luminanceActual);
luminances_mel_high = luminances_mel_high(:,2);

luminances_mel_low = vertcat(validations_mel_low.luminanceActual);
luminances_mel_low = luminances_mel_low(:,2);

luminances = [luminances_mel_low, luminances_mel_high];

% Calculate median, SE of median, CI
luminances_medians = median(luminances,1);
luminances_SEMedians = 1.253*std(luminances)/sqrt(size(luminances,1));
luminances_CIs = luminances_medians + [-1 1]' * luminances_SEMedians;

% Desired luminances
luminances_mel_high_desired = vertcat(validations_mel_high.luminanceDesired);
luminance_mel_high_desired = unique(luminances_mel_high_desired(:,2));

luminances_mel_low_desired = vertcat(validations_mel_low.luminanceDesired);
luminance_mel_low_desired = unique(luminances_mel_low_desired(:,2));
luminances_desired = [luminance_mel_low_desired, luminance_mel_high_desired];

%% Plot luminances
ax = axes(); hold on;
bars_lum = bar(ax, categorical({'Low melanopic','High melanopic'}),[luminances_medians; luminances_desired]);
errorbars_lum_median = errorbar(ax, categorical({'Low melanopic','High melanopic'}),...
                                    bars_lum(1).YData,...
                                    luminances_SEMedians,...
                                    ' .k','CapSize',30);
hold off;
xlabel(ax,'Spectrum');
ylabel(ax,'Luminance (cdm^{-2})');
legend({'Median','Desired'});