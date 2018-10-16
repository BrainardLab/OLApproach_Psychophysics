function measurements = measure(pSpot,oneLight, radiometer)
%% Measure all locations
acceptAll = false;
while ~acceptAll
    %% Define output
    measurements = [];
    
    %% Measure above
    accept = false;
    while ~accept
        pSpot.show();
        oneLight.setAll(true);
        input('<strong>Point the radiometer above the blocker; press any key to start measuring</strong>\n');
        measurement = measureLocation(oneLight, pSpot, radiometer);
        measurement = addvarString(measurement,'above','VariableName','location');
        accept = projectorSpot.acceptMeasurements(measurement);
    end
    measurements = [measurements; measurement];
    
    %% Measure left
    accept = false;
    while ~accept
        pSpot.show();
        oneLight.setAll(true);
        input('<strong>Point the radiometer to the left of the blocker; press any key to start measuring</strong>\n');
        measurement = measureLocation(oneLight, pSpot, radiometer);
        measurement = addvarString(measurement,'left','VariableName','location');
        accept = projectorSpot.acceptMeasurements(measurement);
    end
    measurements = [measurements; measurement];
    
    %% Measure right
    accept = false;
    while ~accept
        pSpot.show();
        oneLight.setAll(true);
        input('<strong>Point the radiometer to the right of the blocker; press any key to start measuring</strong>\n');
        measurement = measureLocation(oneLight, pSpot, radiometer);
        measurement = addvarString(measurement,'right','VariableName','location');
        accept = projectorSpot.acceptMeasurements(measurement);
    end
    measurements = [measurements; measurement];
    
    %% Measure below
    accept = false;
    while ~accept
        pSpot.show();
        oneLight.setAll(true);
        input('<strong>Point the radiometer below blocker; press any key to start measuring</strong>\n');
        measurement = measureLocation(oneLight, pSpot, radiometer);
        measurement = addvarString(measurement,'below','VariableName','location');
        accept = projectorSpot.acceptMeasurements(measurement);
    end
    measurements = [measurements; measurement];
    
    %% Bookkeeping
    measurements.projectorOn = logical(measurements.projectorOn);
    measurements.mirrorsOn = logical(measurements.mirrorsOn);
    measurements.location = categorical(measurements.location);
    
    %% Accept all?
    acceptAll = projectorSpot.acceptMeasurements(measurements);
end

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