function dataMatToResultsCSV(inputFilePath, outputFilePath)
%% Load raw datafile
load(inputFilePath, 'acquisition');

%% Extract results from raw datafile
acquisitionResults = table();
for i = 1:numel(acquisition)
    acquisitionResults = extractResultsFromAcquisition(acquisition(i));
end

%% Save
outputFileDir = fileparts(outputFilePath);
if ~isfolder(outputFileDir)
    mkdir(outputFileDir)
end
writetable(acquisitionResults,outputFilePath);

end