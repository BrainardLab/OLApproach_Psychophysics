function F = plotSPDsRawAll(SPDs)
    F = figure();
    for i = 1:2
        for j = 1:2
            idx = j*2+(i-1)*4;
            doLegend = ~(4-i-j);
            plotSPDsRawLocation(SPDs{i,j},'ax',subplot(3,3,idx),'legend',doLegend);
        end
    end
end