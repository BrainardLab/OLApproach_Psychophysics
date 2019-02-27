function participants = listParticipants
%LISTPARTICIPANTS Summary of this function goes here
%   Detailed explanation goes here
dataRawPath = getpref('MeLMSens_Pulse','ProtocolDataRawPath');
FSEntries = dir(dataRawPath);
directories = FSEntries([FSEntries.isdir]);
directories = directories(~strcmp({directories.name},{'..'}) & ~strcmp({directories.name},{'.'}));
participants = {directories.name};
end