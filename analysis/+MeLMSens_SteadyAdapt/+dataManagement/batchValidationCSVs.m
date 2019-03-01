% List participants
participants = listParticipants();

% Loop over participants
for p = participants
    fprintf('Processing participant %s...',p{:});
    
    sessions = listSessions(p{:});
    
    for s = sessions
        fprintf('\n\tWriting validations tables for session %s...',s{:});
        sessionPath = sessionPathFromName(p{:},s{:});
        outputPath = strrep(sessionPath,'raw','processed');
        validationsCSVsFromName(p{:},s{:}(10:end),outputPath);        
        fprintf('done.');
    end
    
    fprintf('done.\n');
end