function [params] = SessionLog(params,theStep)
% SessionLog -- Session Record Keeping
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
%  06/26/17 mab,jar added switch



switch theStep
    case 'SessionInit'
        
        % Check for prior sessions
        sessionDir = fullfile(getpref(params.theApproach,'SessionRecordsBasePath'),params.observerID,params.todayDate);
        dirString = ls(sessionDir);
        
        if ~isempty(dirString)
            priorSessionNumber = str2double(regexp(dirString, '(?<=session_[^0-9]*)[0-9]*\.?[0-9]+', 'match'))
            currentSessionNumber = max(priorSessionNumber) + 1;
            params.sessionName =['session_' num2str(currentSessionNumber)];
            params.sessionLogOutDir = fullfile(getpref(params.theApproach,'SessionRecordsBasePath'),params.observerID,params.todayDate,params.sessionName);
            if ~exist(params.sessionLogOutDir)
                mkdir(params.sessionLogOutDir)
            end
        else
            currentSessionNumber = 1;
            params.sessionName =['session_' num2str(currentSessionNumber)];
            params.sessionLogOutDir = fullfile(getpref(params.theApproach,'SessionRecordsBasePath'),params.observerID,params.todayDate,params.sessionName);
            if ~exist(params.sessionLogOutDir)
                mkdir(params.sessionLogOutDir)
            end
        end
        
        fileName = [params.observerID '_' params.sessionName '.log'];
        fullFileName = fullfile(params.sessionLogOutDir,fileName)

        fprintf('* <strong> Session Started</strong>: %s\n',params.sessionName)
        fileID = fopen(fullFileName,'a');
        fprintf(fileID,'Experiment Started: %s.\n',params.experiment);
        fprintf(fileID,'Session Number: %s\n',num2str(currentSessionNumber));
        fprintf(fileID,'observerID: %s\n',params.observerID);
        fprintf(fileID,'todayDate: %s\n',datestr(now,'mm-dd-yyyy'));
        fprintf(fileID,'Session Start Time: %s\n',datestr(now,'HH:MM:SS'));
        fclose(fileID);
        
    case 'MakeDirectionCorrectedPrimaries'
        fileID = fopen(fullFileName,'a');
        fclose(fileID);
    case 'MakeModulationStartsStops'
        fileID = fopen(fullFileName,'a');
        fclose(fileID);
    case 'ValidateDirectionCorrectedPrimariesPre'
        fileID = fopen(fullFileName,'a');
        fclose(fileID);
    case 'Demo'
        fileID = fopen(fullFileName,'a');
        fclose(fileID);
    case 'ValidateDirectionCorrectedPrimariesPost'
        fileID = fopen(fullFileName,'a');
        fclose(fileID);
    otherwise
        warning('%s unkown as a step.',theStep)
end

end