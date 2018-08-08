function dataMatToResultsCSV(inputFilePath, outputFilePath)
%% Load raw datafile
load(inputFilePath);

%% Extract results from raw datafile
for i = 1:numel(acquisition)
    acquisitionResults(i).condition = acquisition(i).name;
    acquisitionResults(i).contrast = extractResultsFromAcquisition(acquisition(i))';
end

%% Convert to table
acquisitionResults = struct2table(acquisitionResults);
acquisitionResults = splitvars(acquisitionResults,'contrast','NewVariableNames',{'contrast_L','contrasts_M','contrast_S','contrast_Mel'});

%% Save
outputFileDir = fileparts(outputFilePath);
if ~isdir(outputFileDir)
    mkdir(outputFileDir)
end
writetable(acquisitionResults,outputFilePath);

end