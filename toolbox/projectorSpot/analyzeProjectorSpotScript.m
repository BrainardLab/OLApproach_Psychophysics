lums = SPDsRawToLumsRaw(SPDs,[380 2 201]);
plotSPDsRawAll(SPDs);
plotLumsRawAll(lums);
plotRawAll(SPDs,lums);

lumsTable = lumsToTable(lums);
projectorLumsTable = lumsToProjectorLum(lumsTable);
projectorLumsMeans = projectorLumsMeans(projectorLumsTable);
projectorLumMean = mean(projectorLumsMeans.mean_projectorLum);

%% Average
% - Subtract projector on - off, to get projector SPD, per location per condition
% - Average SPD across OneLight on/off conditions, per location
%   - SEM, CI (95% CI = +- 1.96 SEM)
% - Average SPD across locations
%   - SEM, CI (95% CI = +- 1.96 SEM)

% Luminance, Trolands
% - Take average SPDs
% - Calculate CIE1931 luminance
% - Calculate photopic trolands
% - Calculate CIE1951 scotopic luminance
% - Calculate scotopic trolands