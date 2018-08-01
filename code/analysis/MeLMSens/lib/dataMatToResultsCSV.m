function dataMatToResultsCSV(inputFile)
[inputFileDir, inputFilename] = fileparts(inputFile);

rawDataFilesBasePath = fullfile('.','data','raw');
processedDataFilesBasePath = fullfile('.','data','processed');

outputFileDir = replace(inputFileDir,rawDataFilesBasePath,processedDataFilesBasePath);
if ~isdir(outputFileDir)
    mkdir(outputFileDir)
end

%% Load raw datafile
load(fullfile(inputFileDir,inputFilename));

%% Extract results from raw datafile
for i = 1:numel(acquisition)
    acquisitionResults(i).condition = acquisition(i).name;
    acquisitionResults(i).contrast = extractResultsFromAcquisition(acquisition(i))';
end

%% Convert to table
acquisitionResults = struct2table(acquisitionResults);
acquisitionResults = splitvars(acquisitionResults,'contrast','NewVariableNames',{'contrast_L','contrasts_M','contrast_S','contrast_Mel'});

%% Generate results filename
outputFilename = replace(inputFilename,'data','results');

%% Save
writetable(acquisitionResults,[fullfile(outputFileDir,outputFilename) '.csv']);

end