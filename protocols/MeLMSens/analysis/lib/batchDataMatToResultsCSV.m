matfiles = dir('../../data/raw/*/*/*.mat');
for m = 1:numel(matfiles)
    dirEntry = matfiles(m);
    inputFile = fullfile(dirEntry.folder,dirEntry.name);
    outputFile = replace(inputFile,'raw','processed');
    outputFile = replace(outputFile,'.mat','.csv');
    dataMatToResultsCSV(inputFile,outputFile);
end