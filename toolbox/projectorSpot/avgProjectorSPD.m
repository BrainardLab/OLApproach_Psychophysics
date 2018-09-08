function [SPD, lum] = avgProjectorSPD(projectorSPDTable)
    SPD = mean(projectorSPDTable.deltaSPD)';
    lum = mean(projectorSPDTable.deltaLum);
end