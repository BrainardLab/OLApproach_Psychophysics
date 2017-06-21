function [runCommTest, commTestRepeats] = getCommTestParams()
    % Query user whether we will be running UDP communications delay test
    runCommTest = input('\n Run UDP communications delay test before proceeding with experiment? [y/n] (default: n) ', 's');
    commTestRepeats = [];
    
    if (strcmpi(runCommTest, 'y'))
        runCommTest = true;
        % Ask user how many times to repeat each test
        while (isempty(commTestRepeats))
            commTestRepeats = input('How many repeats to run (e.g., 10, 100) : ');
            if (~isnumeric(commTestRepeats)) || (isempty(commTestRepeats))
                commTestRepeats = [];
            end
        end    
    else
        runCommTest = false;
    end
end
