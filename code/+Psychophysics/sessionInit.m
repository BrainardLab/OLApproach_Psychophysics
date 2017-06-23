function [status, params] = sessionInit(params)

% sessionInit -- Session Initalization 
%
%  Description:
%     This function creates a session specific directory for each subject
%     within an experiment. This will also check for the existance of prior
%     session with the option to append or create new session. This
%     function will output a text file documenting general information
%     about the session **more info to be added here once specifics have
%     been decided on**
%  Output: 
%     status - general output to be decided later.
%     params - updated param struct with session info.

%  06/23/17 mab,jar created file and green text.


params.sessionNumber = 1;
status = 'open';
fprintf('* <strong> Session Started</strong>: session number %s\n',num2str(params.sessionNumber))
end