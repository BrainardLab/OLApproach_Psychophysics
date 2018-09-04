function lums = SPDsRawToLumsRaw(SPDs,S)
    for i = 1:2
        for j = 1:2
            lums{i,j} = cellfun(@(x) SPDToLum(x,S),SPDs{i,j});
        end
    end
end