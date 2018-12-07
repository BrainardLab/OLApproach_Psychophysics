function [luminancesBg, contrastsBg, contrastsFlicker] = validationsToTablesMeLMSens_SteadyAdapt(validations)
%% Background luminances
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
luminancesBg = table;
for bgName = backgroundNames(:)'
    bgValidations = validations(char(bgName));
    
    bgLuminancesActual = vertcat(bgValidations.luminanceActual);
    lumActual = bgLuminancesActual(:,2);
    
    T = table(repmat(bgName,size(lumActual)),lumActual,...
        'VariableNames',{'direction','lumActual'});
    luminancesBg = [luminancesBg; T];
end

%% Background contrasts
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
contrastsBg = table();
for bPair = backgroundNames
    % Extract axis name
    axis = compose("%s-directed backgrounds",extractBefore(bPair(1),"_"));
    
    % Extract validations
    validationsLow = validations(char(bPair(1)));
    validationsHigh = validations(char(bPair(2)));
    
    % Actual contrast
    excitationsActualLow = horzcat(validationsLow.excitationActual);
    excitationsActualLow = excitationsActualLow(:,2:3:end); 
    excitationsActualHigh = horzcat(validationsHigh.excitationActual);
    excitationsActualHigh = excitationsActualHigh(:,2:3:end);   
    contrastsActual = table();
    for i = 1:numel(validationsLow)
        contrastActual = ReceptorExcitationToReceptorContrast([excitationsActualLow(:,i),excitationsActualHigh(:,i)]);
        contrastActual = unipolarContrastsToTable(contrastActual(:,1)*100,{'L','M','S','Mel'});   
        contrastsActual = [contrastsActual; contrastActual];
    end  
    
    % Output table
    axis = table(repmat(axis,[numel(validationsLow) 1]),'VariableNames',{'axis'});
    T = [axis, contrastsActual];
    contrastsBg = [contrastsBg; T];
end

%% Direction contrasts
backgroundNames = ["LMS_low","Mel_low"; "LMS_high", "Mel_high"];
directionNames = "FlickerDirection_" + backgroundNames;
contrastsFlicker = table();

for direction = directionNames(:)' % loop over each flicker direction
    for validation = validations(char(direction))
        T = bipolarValidationTallTable(validation);
        T.direction = repmat(direction,[height(T) 1]);
        contrastsFlicker = [contrastsFlicker; T];
    end
end
contrastsFlicker = contrastsFlicker(:,[end, 1:end-1]);
contrastsFlicker.direction = categorical(contrastsFlicker.direction);
contrastsFlicker = sortrows(contrastsFlicker,{'direction','receptor','time'});

end