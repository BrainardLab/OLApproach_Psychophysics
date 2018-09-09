function T = bipolarValidationTallTable(validation)
% Summary of this function goes here
%   Detailed explanation goes here
receptorStrings = {'L','M','S','Mel'}';
time = repmat(validation.time(1),[length(receptorStrings),1]);

contrastDesired = validation.contrastDesired(:,[1 3]); % desired modulation, not differential, contrast
contrastDesired = table(time, receptorStrings,contrastDesired*100,...
                    'VariableNames',{'time','receptor','desired'}); % convert to table

contrastActual = validation.contrastActual(:,[1 3]); % measured modulation, not differential, contrast
contrastActual = table(time, receptorStrings, contrastActual*100,...
                    'VariableNames',{'time','receptor','actual'});
T = join(contrastDesired, contrastActual);
T.receptor = categorical(T.receptor);
end