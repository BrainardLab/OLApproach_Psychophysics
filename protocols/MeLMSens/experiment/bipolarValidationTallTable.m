function T = bipolarValidationTallTable(validation)
% Summary of this function goes here
%   Detailed explanation goes here
receptorStrings = {'L','M','S','Mel'}';
time = repmat(validation.time(1),[length(receptorStrings),1]);
label = repmat(validation.label,[length(receptorStrings),1]);

contrastDesired = validation.contrastDesired(:,[1 3]); % desired modulation, not differential, contrast
contrastDesired = table(label, time, receptorStrings,round(contrastDesired*100,2),...
                    'VariableNames',{'label','time','receptor','desired'}); % convert to table

contrastActual = validation.contrastActual(:,[1 3]); % measured modulation, not differential, contrast
contrastActual = table(label, time, receptorStrings, contrastActual*100,...
                    'VariableNames',{'label','time','receptor','actual'});
T = join(contrastDesired, contrastActual);
T.receptor = categorical(T.receptor);
end