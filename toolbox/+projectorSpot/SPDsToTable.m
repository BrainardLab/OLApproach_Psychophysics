function T = SPDsToTable(SPDs)
    locations = {"top","left";"right","bottom"};
    onOffMatrix = {[true, true] , [true, false] ;
                   [false, true], [false, false]};
    projectorOn = cellfun(@(x) x(1),onOffMatrix);
    mirrorsOn = cellfun(@(x) x(2),onOffMatrix);
    T = table();
    for i = 1:2
        for j = 1:2
            for k = 1:2
                for l = 1:2
                    SPD = SPDs{i,j}{k,l};
                    t = table(locations{i,j},projectorOn(k,l),mirrorsOn(k,l),SPD',...
                        'VariableNames',{'location','projectorOn','mirrorsOn','SPD'});
                    T = [T; t];
                end
            end
        end
    end
    T.projectorOn = logical(T.projectorOn);
    T.mirrorsOn = logical(T.mirrorsOn);
    T.location = categorical(T.location);
end