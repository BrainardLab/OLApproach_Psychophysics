function [measurements, deltaMeasurements] = measureAutomatic(pSpot, oneLight, radiometer)
%MEASU Summary of this function goes here
%   Detailed explanation goes here

%% Define parameters for translation
originalCenter = pSpot.center;
translateBy = (pSpot.annulusDiameter - pSpot.spotDiameter)/2;

%% Define output
measurements = [];

%% Measure above
pSpot.center = originalCenter;
translation = translateBy * [0, -1; 0 0];
pSpot.translate(translation);
measurement = measureLocation(oneLight, pSpot, radiometer);
measurement = addvarString(measurement,'above','VariableName',"location");
measurements = [measurements; measurement];

%% Measure left
pSpot.center = originalCenter;
translation = translateBy * [-1, 0; 0 0];
pSpot.translate(translation);
measurement = measureLocation(oneLight, pSpot, radiometer);
measurement = addvarString(measurement,'left','VariableName',"location");
measurements = [measurements; measurement];

%% Measure right
pSpot.center = originalCenter;
translation = translateBy * [1, 0; 0 0];
pSpot.translate(translation);
measurement = measureLocation(oneLight, pSpot, radiometer);
measurement = addvarString(measurement,'right','VariableName',"location");
measurements = [measurements; measurement];

%% Measure below
pSpot.center = originalCenter;
translation = translateBy * [0, 1; 0 0];
pSpot.translate(translation);
measurement = measureLocation(oneLight, pSpot, radiometer);
measurement = addvarString(measurement,'below','VariableName',"location");
measurements = [measurements; measurement];

%% Bookkeeping
measurements.projectorOn = logical(measurements.projectorOn);
measurements.mirrorsOn = logical(measurements.mirrorsOn);
measurements.location = categorical(measurements.location);
end

%% Support functions
function measurements = measureLocation(oneLight, pSpot, radiometer)
%
% Inputs:
%
% Outputs:
%    measurements - table, with columns 'time', 'projectorOn', 'mirrorsOn',
%                   'SPD'

%% Define on/off matrix
% Logical array, where each row is a condition in the continency table. In
% each row, there is a logical vector [projectorOn, mirrorsOn]
onOffMatrix = [[true,  true]; [true,  false];...
    [false, true]; [false, false]];

%% Measure conditions
measurements = table;
for i = 1:size(onOffMatrix,1)
    projectorOn = onOffMatrix(i,1);
    mirrorsOn = onOffMatrix(i,2);
    measurement = measureCondition(projectorOn, mirrorsOn, oneLight, pSpot, radiometer);
    measurements = [measurements;measurement];
end
measurements.projectorOn = logical(measurements.projectorOn);
measurements.mirrorsOn = logical(measurements.mirrorsOn);

end

function measurement = measureCondition(projectorOn, mirrorsOn, oneLight, pSpot, radiometer)
%
% Inputs:
%
% Outputs:
%    measurement - table(row), with columns 'time', 'projectorOn',
%                  'mirrorsOn', 'SPD'
if projectorOn
    pSpot.show();
else
    pSpot.hide();
end
oneLight.setAll(mirrorsOn);
time = datetime;
if ~isempty(radiometer)
    SPD = radiometer.measure();
else
    SPD = projectorOn*.0005*ones(201,1)' + mirrorsOn*.03*ones(201,1)';
end
time = [time datetime];
measurement = table(time, projectorOn, mirrorsOn, SPD);

end