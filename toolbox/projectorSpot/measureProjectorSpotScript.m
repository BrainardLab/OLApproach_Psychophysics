%% Get a general sense of projector spot SPD
% Measure SPDs around non-blocked region, in several locations
clear all; close all; clc;
approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Get projectorSpot
pSpot = projectorSpot(~simulate.projector);
pSpot.show();

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

%% Measure SPDs
SPDs = measureProjectorSpot(pSpot, oneLight,radiometer);

%% Turn off hardware
oneLight.close();
pSpot.close();
if ~isempty(radiometer)
    radiometer.shutDown();
end