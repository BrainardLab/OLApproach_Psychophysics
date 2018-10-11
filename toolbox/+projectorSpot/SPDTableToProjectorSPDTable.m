function projectorSPDTable = SPDTableToProjectorSPDTable(SPDTable)
    [G, TID] = findgroups(SPDTable(:,[1,3]));
    deltaSPD = splitapply(@(x) diff(flipud(x)),SPDTable.SPD,G);
    deltaLum = splitapply(@(x) diff(flipud(x)),SPDTable.luminance,G);
    projectorSPDTable = [TID, table(deltaSPD, deltaLum)];
end