% Load dummy staircase
s = Staircase('standard',.05,[1],[1],[1]);

% List participants
participants = listParticipants();

% Loop over participants
for p = participants
    fprintf('Processing participant %s...',p{:});
    
    sessions = listSessions(p{:});
    
    for s = sessions
        fprintf('\n\tPrinting session %s...',s{:});
        sessionFig(p{:},s{:});
        fprintf('done.');
    end
    
    fprintf('done.\n');
end