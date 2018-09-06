function F = plotValidationSummary(luminancesDesired, luminancesActual, contrastsBgActual, contrastsFlickerActual)
F = figure();

% Plot background luminances
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
axLum = subplot(1,3,1); hold on;
bar([luminancesDesired, luminancesActual]);
xticks(1:4);
xticklabels(replace(backgroundNames,'_',' '));
legend('desired','actual');
ylabel('Luminance (CIE1931 cd/m^2)');
title('Background luminances');

% Plot background contrasts
axBgContrasts = subplot(1,3,2); hold on;
bars = bar(table2array(contrastsBgActual)');
plot(xlim,[5 5],'r:');
plot(xlim,[350 350],'r:');
ylabel('Receptor contrast (%)');
xticks(1:4);
xticklabels({'L','M','S','Mel'});
xlabel('Receptor');
axBgContrasts.YScale = 'log';
legend(replace(contrastsBgActual.Properties.RowNames,'_',' '));
title('Background contrasts')

% Plot flicker contrasts
axFlickerContrasts = subplot(1,3,3); hold on;
datamat = table2array(contrastsFlickerActual)';
clear stackData;
stackData(:,:,1) = datamat(1:2:end,:);
stackData(:,:,2) = -stackData(:,:,1)+datamat(2:2:end,:);
bars = plotBarStackGroups(stackData,...
    {'L','M','S','Mel'});
hold on;
plot(xlim,[-5 -5],'r:');
plot(xlim,[5 5],'r:');
ylabel('Receptor contrast (%)');
xlabel('Receptor');
title('Flicker direction contrasts');
legend(bars(:,2),replace(contrastsFlickerActual.Properties.RowNames,'_',' '));
end