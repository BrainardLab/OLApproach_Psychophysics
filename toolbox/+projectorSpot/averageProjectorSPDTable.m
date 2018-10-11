function avgProjectorSPDTable = averageProjectorSPDTable(projectorSPDTable)
%AVERAGEPROJECTORSPDTABLE Summary of this function goes here
%   Detailed explanation goes here
    [G, TID] = findgroups(projectorSPDTable.location);
    lum = splitapply(@(x) [mean(x), ([-1.96, +1.96] .* std(x)/sqrt(length(x)))+mean(x)],...
                    projectorSPDTable.deltaLum,G);
    lum = table(lum(:,1), lum(:,2:3),'VariableNames',{'LumMean','LumCI'});
    lum.location = TID; %lum = movevars(lum,'location','Before',1);
    SPDmean = splitapply(@mean,projectorSPDTable.deltaSPD,G); 
    avgProjectorSPDTable = lum;
    avgProjectorSPDTable.SPD = SPDmean;
end