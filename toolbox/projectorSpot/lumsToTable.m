function lumsTable = lumsToTable(lums)
%LUMSTABLE Summary of this function goes here
%   Detailed explanation goes here
    locations = {"top","left";"right","bottom"};
    lumsTable = table();
    for i = 1:2
        for j = 1:2
            locationTable = lumsLocationToTable(lums{i,j});
            locationTable.location = repmat(locations{i,j},[4 1]);
            lumsTable = [lumsTable; locationTable];
        end
    end
    lumsTable.projectorOn = logical(lumsTable.projectorOn);
    lumsTable.mirrorsOn = logical(lumsTable.mirrorsOn);
    lumsTable.location = categorical(lumsTable.location);
end

function lumsTable = lumsLocationToTable(lums)
onOffMatrix = {[true, true] , [true, false] ;
    [false, true], [false, false]};
projectorOn = cellfun(@(x) x(1),onOffMatrix);
mirrorsOn = cellfun(@(x) x(2),onOffMatrix);

lumsTable = table(projectorOn(:),mirrorsOn(:),lums(:),...
                  'VariableNames',{'projectorOn','mirrorsOn','lum'});
    
end