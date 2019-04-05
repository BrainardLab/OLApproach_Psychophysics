function sessions = listSessions(participant)
%LISTSESSIONS Summary of this function goes here
%   Detailed explanation goes here
dataRawPath = getpref('MeLMSens_SteadyAdapt','ProtocolDataRawPath');
FSEntries = dir(fullfile(dataRawPath,participant,'*session*'));
directories = FSEntries([FSEntries.isdir]);
directories = directories(~strcmp({directories.name},{'..'}) & ~strcmp({directories.name},{'.'}));
sessions = {directories.name};
end