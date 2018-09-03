function SPDs = measureSPDInFourLocations(obj,oneLight, radiometer)
%% Define on/off matrix
% Cell array, where each cell is a condition in the continency table. In
% each cell, there is a logical vector [projectorOn, mirrorsOn]
onOffMatrix = {[true, true] , [true, false] ;
    [false, true], [false, false]};

%% Define output
SPDs = cell(2,2);

%% Measure above
obj.show();
oneLight.setAll(true);
input('<strong>Point the radiometer above the blocker; press any key to start measuring</strong>\n');
SPDs{1,1} = measureLocation(onOffMatrix, oneLight, obj, radiometer);

%% Measure left
obj.show();
oneLight.setAll(true);
input('<strong>Point the radiometer to the left of the blocker; press any key to start measuring</strong>\n');
SPDs{1,2} = measureLocation(onOffMatrix, oneLight, obj, radiometer);

%% Measure right
obj.show();
oneLight.setAll(true);
input('<strong>Point the radiometer to the right of the blocker; press any key to start measuring</strong>\n');
SPDs{2,1} = measureLocation(onOffMatrix, oneLight, obj, radiometer);

%% Measure below
obj.show();
oneLight.setAll(true);
input('<strong>Point the radiometer below blocker; press any key to start measuring</strong>\n');
SPDs{2,2} = measureLocation(onOffMatrix, oneLight, obj, radiometer);
end

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
    SPD = radiometer.measure()';
else
    SPD = (projectorOn+3*mirrorsOn+1)*ones(201,1);
end
end