function [projSPD, projLum] = analyze(SPDTable)
    %% Define wavelength sampling
    S = [380 2 201];

    %% Add luminance as column to table
    % Calculate CIE1931 luminance
    SPDTable = projectorSpot.addColumnLum(SPDTable,S);

    %% Compute delta projectorOn-projectorOff
    % - Subtract projector on - off, to get projector SPD, per location per condition
    projectorSPDTable = projectorSpot.SPDTableToProjectorSPDTable(SPDTable);

    %% Average over mirrorsOn/mirrorsOff, per location
    % - Average SPD across OneLight on/off conditions, per location
    %   - SEM, CI (95% CI = +- 1.96 SEM)
    %projectorSPDTable = projectorSpot.averageProjectorSPDTable(projectorSPDTable);

    %% Average over locations
    % - Average SPD across locations
    %   - SEM, CI (95% CI = +- 1.96 SEM)
    [projSPD, projLum] = projectorSpot.avgProjectorSPD(projectorSPDTable);
    if any(projSPD(:) < 0)
        warning('average projector SPD contains negative values. Truncating these to 0');
        projSPD(projSPD < 0) = 0;
    end

    %% Luminance, Trolands
    % - Take average SPDs
    % - Calculate photopic trolands
    % - Calculate CIE1951 scotopic luminance
    % - Calculate scotopic trolands
end