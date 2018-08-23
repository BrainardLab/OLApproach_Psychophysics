function dataMatToResultsCSV(inputFilePath, outputFilePath)
%% Load raw datafile
load(inputFilePath);

%% Extract results from raw datafile
for i = 1:numel(acquisition)
    acquisitionResults(i).condition = acquisition(i).name;
    [contrast, excitationPos, excitationNeg, excitationBackground] = extractResultsFromAcquisition(acquisition(i));
    acquisitionResults(i).contrast = contrast';
    acquisitionResults(i).excitationPos = excitationPos';
    acquisitionResults(i).excitationNeg = excitationNeg';
    acquisitionResults(i).excitationBackground = excitationBackground';
end

%% Convert to table
acquisitionResults = struct2table(acquisitionResults);
acquisitionResults = splitvars(acquisitionResults,'contrast','NewVariableNames',{'contrast_L','contrasts_M','contrast_S','contrast_Mel'});
acquisitionResults = splitvars(acquisitionResults,'excitationPos','NewVariableNames',{'excitationPos_L','excitationPos_M','excitationPos_S','excitationPos_Mel'});
acquisitionResults = splitvars(acquisitionResults,'excitationNeg','NewVariableNames',{'excitationNeg_L','excitationNeg_M','excitationNeg_S','excitationNeg_Mel'});
acquisitionResults = splitvars(acquisitionResults,'excitationBackground','NewVariableNames',{'excitationBackground_L','excitationBackground_M','excitationBackground_S','excitationBackground_Mel'});

%% Save
outputFileDir = fileparts(outputFilePath);
if ~isdir(outputFileDir)
    mkdir(outputFileDir)
end
writetable(acquisitionResults,outputFilePath);

end