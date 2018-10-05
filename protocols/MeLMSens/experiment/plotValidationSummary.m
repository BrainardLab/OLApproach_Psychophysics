function F = plotValidationSummary()
F = figure();

% Plot background luminances
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
axLum = subplot(1,3,1); hold on;
xticks(1:4);
xticklabels(replace(backgroundNames,'_',' '));
ylabel('Luminance (CIE1931 cd/m^2)');
title('Background luminances');

% Plot background contrasts
axBgContrasts = subplot(1,3,2); hold on;
plot(xlim,[5 5],'r:');
plot(xlim,[350 350],'r:');
ylabel('Receptor contrast (%)');
xticks(1:4);
xticklabels({'L','M','S','Mel'});
xlabel('Receptor');
axBgContrasts.YScale = 'log';
title('Background contrasts')

% Plot flicker contrasts
axFlickerContrasts = subplot(1,3,3); hold on;
hold on;
plot(xlim,[-5 -5],'r:');
plot(xlim,[5 5],'r:');
ylabel('Receptor contrast (%)');
xlabel('Receptor');
title('Flicker direction contrasts');
end