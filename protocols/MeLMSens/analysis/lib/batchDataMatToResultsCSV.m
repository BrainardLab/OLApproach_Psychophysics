matfiles = dir('../../data/raw/*/*/data-*.mat');
fprintf('Found files:\n');
fprintf('\t%s\n',matfiles.name);

fprintf('\n');
for m = 1:numel(matfiles)
    dirEntry = matfiles(m);
    fprintf('Processing file %s...',dirEntry.name);
    if contains(dirEntry.name,'pilot')
        fprintf('pilot file; skipped.\n');
        continue;
    end
    inputFile = fullfile(dirEntry.folder,dirEntry.name);
    outputFile = replace(inputFile,'raw','processed');
    outputFile = replace(outputFile,'.mat','.csv');
    outputFile = replace(outputFile,'data-','results_acquisition-');
    dataMatToResultsCSV(inputFile,outputFile);
    fprintf('saved to %s.\n',outputFile);
end