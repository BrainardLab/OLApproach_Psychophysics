function projectorLumsMeans = projectorLumsMeans(projectorLumTable)
%PROJECTORMEANLUMS Summary of this function goes here
%   Detailed explanation goes here
    projectorLumsMeans = varfun(@mean,projectorLumTable,...
                        'InputVariables','projectorLum',...
                        'GroupingVariables','location');
    projectorLumsMeans.GroupCount = [];
end