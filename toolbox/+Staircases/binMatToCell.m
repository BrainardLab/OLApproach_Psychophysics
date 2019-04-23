function binnedCell = binMatToCell(X,binIdc)
%BINMATTOCELL Place numeric array entries in bins by specified indices
%   binnedCell = binMatToCell(X, binIndices) bins the entries in
%   X into a cell-array, according to the binIndices. The binnedCell
%   output cell specifies one cell per bin, where each cell contains a
%   numeric vector with the entries from X in that bin. binIndices is of
%   size(X), and specifies for each entry in X the index of the bin in
%   binnedCell.

% History:
%   2019.03.27  J.Vincent wrote binMatToCell

binnedCell = cell(max(binIdc(:)),size(X,2));
for i = 1:numel(X) % loop over every entry of array
    binIdx = binIdc(i); % what bin should this array entry go in?
    val = X(i);       % what is the value that should go into that bin?
    
    binnedCell{binIdx} = [binnedCell{binIdx}, val]; % append value to whatever is in bin
end
end