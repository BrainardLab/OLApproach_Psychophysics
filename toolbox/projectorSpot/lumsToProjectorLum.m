function projectorLumTable = lumsToProjectorLum(lumsTable)
%LUMSTOPROJECTORLUM Summary of this function goes here
%   Detailed explanation goes here
    projectorLumTable = varfun(@(x) x(1)-x(2),lumsTable,'InputVariables','lum',...
       'GroupingVariables',{'location','mirrorsOn'});
    projectorLumTable.projectorLum = projectorLumTable.Fun_lum;
    projectorLumTable.Fun_lum = [];
    projectorLumTable.GroupCount = [];
end