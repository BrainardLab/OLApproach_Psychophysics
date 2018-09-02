%% Get a general sense of projector spot SPD
% Measure SPDs around non-blocked region, in several locations

approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Open the OneLight
% Open up a OneLight device
oneLight = OneLight('simulate',simulate.oneLight); drawnow;

%% Get radiometer
% Open up a radiometer, which we will need later on.
if ~simulate.radiometer
    oneLight.setAll(true);
    commandwindow;
    input('<strong>Turn on radiometer and connect to USB; press any key to connect to radiometer</strong>\n');
    oneLight.setAll(false);
    pause(3);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
else
    radiometer = [];
end

%% Get projectorSpot
pSpot = projectorSpot('Fullscreen',~simulate.projector);
pSpot.show();

%% Define on/off matrix
% Cell array, where each cell is a condition in the continency table. In
% each cell, there is a logical vector [projectorOn, mirrorsOn]
onOffMatrix = {[true, true] , [true, false] ;
    [false, true], [false, false]};

%% Define output
measurements = cell(2,2);

%% Measure above
input('<strong>Point the radiometer above the blocker; press any key to start measuring</strong>\n');
measurements{1,1} = measureLocation(onOffMatrix, oneLight, pSpot, radiometer);

%% Measure left
input('<strong>Point the radiometer to the left of the blocker; press any key to start measuring</strong>\n');
measurements{1,2} = measureLocation(onOffMatrix, oneLight, pSpot, radiometer);

%% Measure right
input('<strong>Point the radiometer to the right of the blocker; press any key to start measuring</strong>\n');
measurements{2,1} = measureLocation(onOffMatrix, oneLight, pSpot, radiometer);

%% Measure below
input('<strong>Point the radiometer below blocker; press any key to start measuring</strong>\n');
measurements{2,2} = measureLocation(onOffMatrix, oneLight, pSpot, radiometer);

%% Turn off hardware
oneLight.close();
pSpot.close();
if ~isempty(radiometer)
    radiometer.shutDown();
end

%% Plot
plotAll(measurements)

%% Support functions
function SPDs = measureLocation(onOffMatrix, oneLight, pSpot, radiometer)
SPDs = cell(size(onOffMatrix));
for i = 1:size(onOffMatrix,1)
    for j = 1:size(onOffMatrix,2)
        projectorOn = onOffMatrix{i,j}(1);
        mirrorsOn = onOffMatrix{i,j}(2);
        SPDs{i,j} = measureCondition(projectorOn, mirrorsOn, oneLight, pSpot, radiometer);
    end
end
end

function SPD = measureCondition(projectorOn, mirrorsOn, oneLight, pSpot, radiometer)
if projectorOn
    pSpot.show();
else
    pSpot.hide();
end
oneLight.setAll(mirrorsOn);
if ~isempty(radiometer)
    SPD = radiometer.measure();
else
    SPD = (projectorOn+3*mirrorsOn+1)*ones(201,1);
end
end

function lum = SPDToLum(SPD,S)
load('T_xyz1931.mat','*_xyz1931');
T_xyz = SplineCmf(S_xyz1931,T_xyz1931,S);
T_xyz = 683*T_xyz;
lum = T_xyz(2,:) * SPD;
end

function lums = SPDsLocationToLums(SPDs,S)
lums = cellfun(@(x) SPDToLum(x,S),SPDs);
% lums = SPDToLum(cell2mat(SPDs(:)'),S);
% lums = [lums([1,3]); lums([2, 4])];
end

function plotSPDsForLocation(SPDs, ax)
parser = inputParser;
parser.addRequired('SPDs',@iscell);
axes(ax); hold on;
plot(SPDs{1,1} ,'g-');
plot(SPDs{2,1},'r-');
plot(SPDs{1,2},'g:');
plot(SPDs{2,2},'r:');
xlim([1, length(SPDs{1,1})]);
% legend({'projector on, mirrors on', 'projector Off, mirrors On',...
%     'projector on, mirrors off', 'projector off, mirrors off'},...
%     'NumColumns',2);
end

function plotLumsForLocation(lums, ax)
parser = inputParser;
parser.addRequired('SPDs',@iscell);
axes(ax); hold on;
bar(lums);
xticks([1 2]);
xticklabels({'on', 'off'});
%legend('mirrors on','mirrors off');
end

function F = plotAll(measurements, varargin)
    F = figure();
    for i = 1:2
        for j = 1:2
            idxs = j*4+(i-1)*8+[-1 0];
            M = measurements{i,j};
            plotSPDsForLocation(M,subplot(3,6,idxs(1)));
            plotLumsForLocation(SPDsLocationToLums(M,[380 2 201]),subplot(3,6,idxs(2)))
        end
    end
end

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