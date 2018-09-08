%% Convert to table
SPDTable = SPDsToTable(SPDs);

%% Define wavelength sampling
S = [380 2 201];

%% Add luminance as column to table
% Calculate CIE1931 luminance
SPDTable = addColumnLum(SPDTable,S);

%% Compute delta projectorOn-projectorOff
% - Subtract projector on - off, to get projector SPD, per location per condition
projectorSPDTable = SPDTableToProjectorSPDTable(SPDTable);

%% Average over mirrorsOn/mirrorsOff, per location
% - Average SPD across OneLight on/off conditions, per location
%   - SEM, CI (95% CI = +- 1.96 SEM)
averageProjectorSPDTable(projectorSPDTable);

%% Average over locations
% - Average SPD across locations
%   - SEM, CI (95% CI = +- 1.96 SEM)
[projSPD, projLum] = avgProjectorSPD(projectorSPDTable);

%% Plot
plotSPDsRawAll(SPDs);
% plotLumsRawAll(lums);
% plotRawAll(SPDs,lums);

%% Luminance, Trolands
% - Take average SPDs
% - Calculate photopic trolands
% - Calculate CIE1951 scotopic luminance
% - Calculate scotopic trolands