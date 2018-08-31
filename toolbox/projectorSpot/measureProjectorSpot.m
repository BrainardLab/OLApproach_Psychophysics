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
projectorWindow = makeProjectorSpot('Fullscreen',~simulate.projector); % make projector spot window object
toggleProjectorSpot(projectorWindow,true); % toggle on

%% Define on/off matrix
% Cell array, where each cell is a condition in the continency table. In
% each cell, there is a logical vector [projectorOn, mirrorsOn]
onOffMatrix = {[true, true] , [true, false] ;
               [false, true], [false, false]};

%% Define output
measurements = cell(2,2);
           
%% Measure above
input('<strong>Point the radiometer above the blocker; press any key to start measuring</strong>\n');
measurements{1,1} = measureLocation(onOffMatrix, oneLight, projectorWindow, radiometer);

%% Measure right
input('<strong>Point the radiometer to the right of the blocker; press any key to start measuring</strong>\n');
measurements{1,2} = measureLocation(onOffMatrix, oneLight, projectorWindow, radiometer);

%% Measure left
input('<strong>Point the radiometer to the left of the blocker; press any key to start measuring</strong>\n');
measurements{2,1} = measureLocation(onOffMatrix, oneLight, projectorWindow, radiometer);

%% Measure below
input('<strong>Point the radiometer below blocker; press any key to start measuring</strong>\n');
measurements{2,2} = measureLocation(onOffMatrix, oneLight, projectorWindow, radiometer);

%% Turn off hardware
oneLight.close();
projectorWindow.close();
if ~isempty(radiometer)
    radiometer.shutDown();
end

%% Plot
plotAll(measurements)

%% Support functions
function SPDs = measureLocation(onOffMatrix, oneLight, projectorWindow, radiometer)
    SPDs = cell(size(onOffMatrix));
    for i = 1:size(onOffMatrix,1)
        for j = 1:size(onOffMatrix,2)
            projectorOn = onOffMatrix{i,j}(1);
            mirrorsOn = onOffMatrix{i,j}(2);
            SPDs{i,j} = measureCondition(projectorOn, mirrorsOn, oneLight, projectorWindow, radiometer);
        end
    end
end

function SPD = measureCondition(projectorOn, mirrorsOn, oneLight, projectorWindow, radiometer)
    toggleProjectorSpot(projectorWindow,projectorOn); % toggle on
    oneLight.setAll(mirrorsOn);
    if ~isempty(radiometer)
        SPD = radiometer.measure();
    else
        SPD = (projectorOn+1)*ones(201,1);
    end
end

function [ax1, ax2] = plotSPDsForLocation(SPDs, varargin)
parser = inputParser;
parser.addRequired('SPDs',@iscell);
ax1 = subplot(1,2,1);
plot(SPDs{1,1},'g');
plot(SPDs{2,1},'r');
xlim([1, length(SPDs{1,1})]);
ax2 = subplot(1,2,2);
plot(SPDs{1,2},'g');
plot(SPDs{2,2},'r');
xlim([1, length(SPDs{1,2})]);
end

function F = plotAll(measurements, varargin)
    for i = 1:size(measurements,1)
        for j = 1:size(measurements,2)
            Figs{i,j} = {plotSPDsForLocation(measurements{i,j})};
        end
    end
    
    F = figure();
    subplot(3,6,3,Figs{i,j}(1));
    
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