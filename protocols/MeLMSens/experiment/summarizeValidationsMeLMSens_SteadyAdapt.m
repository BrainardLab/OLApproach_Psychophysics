function [luminancesActual, contrastsBgActual, contrastsFlickerActual] = summarizeValidationsMeLMSens_SteadyAdapt(validations)

%% Background luminances
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
luminancesActual = [];
luminancesDesired = [];
for bb = backgroundNames(:)'
    luminancesDesired = [luminancesDesired; validations(char(bb)).luminanceDesired(2)];
    luminancesActual = [luminancesActual; validations(char(bb)).luminanceActual(2)];
end

% Plot
figure();
axLum = axes(); hold on;
bar([luminancesDesired, luminancesActual]);
xticks(1:4);
xticklabels(backgroundNames);
legend('desired','actual');
ylabel('Luminance (CIE1931 cd/m^2)');

%% Background contrasts
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
contrastsBgDesired = table();
contrastsBgActual = table();
for bPair = backgroundNames
    excitationsDesired = [validations(char(bPair(1))).excitationDesired(:,2),validations(char(bPair(2))).excitationDesired(:,2)];
    contrastDesired = ReceptorExcitationToReceptorContrast(excitationsDesired);
    contrastDesired = round(contrastDesired(:,1)*100,1);
    contrastDesired = unipolarContrastsToTable(contrastDesired,{'L','M','S','Mel'});
    contrastDesired.Properties.RowNames = cellstr(compose('%s-directed backgrounds',extractBefore(bPair(1),"_")));   
    contrastsBgDesired = [contrastsBgDesired; contrastDesired];
    
    excitationsActual = [validations(char(bPair(1))).excitationActual(:,2),validations(char(bPair(2))).excitationActual(:,2)];
    contrastActual = ReceptorExcitationToReceptorContrast(excitationsActual);
    contrastActual = unipolarContrastsToTable(contrastActual(:,1)*100,{'L','M','S','Mel'});   
    contrastActual.Properties.RowNames = cellstr(compose('%s-directed backgrounds',extractBefore(bPair(1),"_")));
    
    contrastsBgActual = [contrastsBgActual; contrastActual];
end

% Plot background contrasts
figure();
axBgContrasts = axes(); hold on;
bars = bar(table2array(contrastsBgActual)');
plot(xlim,[5 5],'r:');
plot(xlim,[350 350],'r:');
ylabel('Receptor contrast (%)');
xticks(1:4);
xticklabels({'L','M','S','Mel'});
xlabel('Receptor');
axBgContrasts.YScale = 'log';
legend(replace(contrastsBgActual.Properties.RowNames,'_',' '));

%% Direction contrasts
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
directionNames = "FlickerDirection_" + backgroundNames;
contrastsFlickerActual = table();
contrastsFlickerDesired = table;
for dd = directionNames(:)' % loop over each flicker direction
    validation = validations(char(dd));
    contrastDesired = validation.contrastDesired(:,[1 3]); % desired modulation, not differential, contrast    
    contrastDesired = bipolarContrastsToTable(contrastDesired,{'L','M','S','Mel'}); % convert to table 
    contrastDesired.Properties.RowNames = cellstr(dd); % add direction name
    contrastsFlickerDesired = [contrastsFlickerDesired; contrastDesired];
    
    contrastActual = validation.contrastActual(:,[1 3]); % measured modulation, not differential, contrast
    contrastActual = bipolarContrastsToTable(contrastActual,{'L','M','S','Mel'}); % convert to table
    contrastActual.Properties.RowNames = cellstr(dd); % add direction name
    contrastsFlickerActual = [contrastsFlickerActual; contrastActual];
end

% Plot flicker contrasts
figure();
axFlickerContrasts = axes(); hold on;
bars = bar(table2array(contrastsFlickerActual)');
ylabel('Receptor contrast (%)');
xticks(1:4);
xticklabels({'L','M','S','Mel'});
xlabel('Receptor');
legend(replace(contrastsFlickerActual.Properties.RowNames,'_',' '));
end