function [luminancesBg, contrastsBg, contrastsFlicker] = summarizeValidationsMeLMSens_SteadyAdapt(validations)
%% Background luminances
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
luminancesBg = table;
for bgName = backgroundNames(:)'
    bgValidations = validations(char(bgName));
    
    bgLuminancesDesired = vertcat(bgValidations.luminanceDesired);
    lumDesired = bgLuminancesDesired(:,2);
    
    bgLuminancesActual = vertcat(bgValidations.luminanceActual);
    lumActual = bgLuminancesActual(:,2);
    
    T = table(repmat(bgName,size(lumActual)),lumDesired,lumActual,...
        'VariableNames',{'direction','lumDesired','lumActual'});
    luminancesBg = [luminancesBg; T];
end

%% Background contrasts
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
contrastsBg = table();
for bPair = backgroundNames
    axis = compose('%s-directed backgrounds',extractBefore(bPair(1),"_"));
    validationsLow = validations(char(bPair(1)));
    validationsHigh = validations(char(bPair(2)));
    
    excitationsDesiredLow = horzcat(validationsLow.excitationDesired);
    excitationsDesiredLow = excitationsDesiredLow(:,2:3:end);
    
    excitationsDesiredHigh = horzcat(validationsHigh.excitationDesired);
    excitationsDesiredHigh = excitationsDesiredHigh(:,2:3:end);
    
    for i = 1:numel(validationsLow)
        contrastDesired = ReceptorExcitationToReceptorContrast([excitationsDesiredLow(:,i),excitationsDesiredHigh(:,i)]);
        contrastDesired = round(contrastDesired(:,1)*100,1); 
        contrastDesired = unipolarContrastsToTable(contrastDesired,{'L','M','S','Mel'});
    end

    excitationsActualLow = horzcat(validationsLow.excitationDesired);
    excitationsActualLow = excitationsActualLow(:,2:3:end);
    
    excitationsActualHigh = horzcat(validationsHigh.excitationDesired);
    excitationsActualHigh = excitationsActualHigh(:,2:3:end);
    
    for i = 1:numel(validationsLow)
        contrastActual = ReceptorExcitationToReceptorContrast([excitationsActualLow(:,i),excitationsActualHigh(:,i)]);
        contrastActual = unipolarContrastsToTable(contrastActual(:,1)*100,{'L','M','S','Mel'});   
    end
    T = table(axis,contrastDesired,contrastActual);
    contrastsBg = [contrastsBg; T];
end

%% Direction contrasts
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
directionNames = "FlickerDirection_" + backgroundNames;
contrastsFlicker = table();

for direction = directionNames(:)' % loop over each flicker direction
    for validation = validations(char(direction))
        contrastDesired = validation.contrastDesired(:,[1 3]); % desired modulation, not differential, contrast    
        contrastDesired = bipolarContrastsToTable(contrastDesired*100,{'L','M','S','Mel'}); % convert to table 

        contrastActual = validation.contrastActual(:,[1 3]); % measured modulation, not differential, contrast
        contrastActual = bipolarContrastsToTable(contrastActual*100,{'L','M','S','Mel'}); % convert to table
        
        T = table(direction,contrastDesired,contrastActual);
        contrastsFlicker = [contrastsFlicker; T];
    end
end

end