function [projSPD, projLum] = analyze(measurements)
    %% Define wavelength sampling
    S = [380 2 201];

    %% Add luminance as column to table
    % Calculate CIE1931 luminance
    measurements = addvarLum(measurements,S);

    %% Compute delta projectorOn-projectorOff
    % Subtract projector on - off, to get projector SPD, per location per
    % condition
    [G, TID] = findgroups(measurements(:,{'location','mirrorsOn'}));
    SPD = splitapply(@(x) diff(flipud(x)),measurements.SPD,G);
    Lum = splitapply(@(x) diff(flipud(x)),measurements.luminance,G);
    deltaMeasurements = [TID, table(SPD, Lum)];
    
    %% Average over mirrorsOn/mirrorsOff, per location
    % Average SPD across OneLight on/off conditions, per location
    % SEM, CI (95% CI = +- 1.96 SEM)
    [G, TID] = findgroups(deltaMeasurements.location);
    lum = splitapply(@(x) [mean(x), ([-1.96, +1.96] .* std(x)/sqrt(length(x)))+mean(x)],...
                    deltaMeasurements.Lum,G);
    lum = table(lum(:,1), lum(:,2:3),'VariableNames',{'LumMean','LumCI'});
    lum.location = TID; %lum = movevars(lum,'location','Before',1);
    SPDmean = splitapply(@mean,deltaMeasurements.SPD,G); 
    avgProjectorSPDTable = lum;
    avgProjectorSPDTable.SPD = SPDmean;

    %% Average over locations
    % Average SPD across locations
    % SEM, CI (95% CI = +- 1.96 SEM)
    projSPD = mean(deltaMeasurements.SPD)';
    if any(projSPD(:) < 0)
        warning('average projector SPD contains negative values. Truncating these to 0');
        projSPD(projSPD < 0) = 0;
    end
    projLum = mean(deltaMeasurements.Lum);    

    %% Luminance, Trolands
    % Take average SPDs
    % Calculate photopic trolands
    % Calculate CIE1951 scotopic luminance
    % Calculate scotopic trolands
end