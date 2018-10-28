matfiles = dir('../../data/raw/*/*/data-*.mat');
for m = 1:numel(matfiles)
    dirEntry = matfiles(m);
    inputFile = fullfile(dirEntry.folder,dirEntry.name);
    outputFile = replace(inputFile,'raw','processed');
    outputFile = replace(outputFile,'.mat','.csv');
    outputFile = replace(outputFile,'data-','results_acquisition-');
    dataMatToResultsCSV(inputFile,outputFile);
end