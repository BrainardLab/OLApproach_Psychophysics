function binCenter = binEdgesToCenter(binEdges)
%BINCENTERFROMEDGES calculate center of bin from bin edges 
%   binCenter = binCenterFromEdges(staircase)
%   returns a vector of binCenters, specifying the center value of each bin

% History:
%   2019.03.27  J.Vincent wrote staircaseProportionCorrect
%   2019.04.22  J.Vincent extracted binEdgesToCenter

%% Calculate binCenters
binCenter = ((binEdges(2:end)-binEdges(1:end-1))/2+binEdges(1:end-1))';

end