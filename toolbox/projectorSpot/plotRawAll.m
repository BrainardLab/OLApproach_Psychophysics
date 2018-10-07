function F = plotRawAll(SPDs,lums)
    F = figure();
    for i = 1:2
        for j = 1:2
            idxs = j*4+(i-1)*8+[-1 0];
            plotSPDsRawLocation(SPDs{i,j},'ax',subplot(3,6,idxs(1)),'legend',false);
            plotLumsRawLocation(lums{i,j},'ax',subplot(3,6,idxs(2)),'legend',false)
        end
    end
end