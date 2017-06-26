function [status, params] = SessionInit(params,theFunction)

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


sessionNumber = 1; % needs to go into dirs and search for sessions and not be hard-coded to 1.
params.sessionName =['session_' num2str(sessionNumber)];
status = 'open';
fprintf('* <strong> Session Started</strong>: %s\n',params.sessionName)
outDir = fullfile(getpref(params.theApproach,'SessionRecordsBasePath'),params.observerID,params.todayDate,params.sessionName);
if ~exist(outDir)
    mkdir(outDir)
end

filename = [params.observerID '_' params.sessionName '.log'];

switch theFunction
    case 'SessionInit'
        fileID = fopen(filename,'w');
        fprintf(fileID,'test of the print\n');
        fprintf(fileID,'Date: %',params.todayDate);
        fclose(fileID);
    case 'MakeDirectionNominalPrimaries'
        
    case 'MakeDirectionCorrectedPrimaries'
        
    case 'MakeModulationStartsStops'
        
    case 'ValidateDirectionCorrectedPrimaries'
        
end

end