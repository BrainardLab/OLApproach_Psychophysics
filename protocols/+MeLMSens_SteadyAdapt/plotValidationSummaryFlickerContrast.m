%function plotValidationSummaryFlickerContrast(avgContrastsFlicker)
% Plot
%
% Description:
%    Plots a summary of the validations of the flicker directions. Plots a
%    panel per receptor, and a (stacked) bar per direction.


% Get indices for bar, panel
barIdxs = avgContrastsFlicker.direction;
panelIdxs = avgContrastsFlicker.receptor;

splitapply()


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

%end