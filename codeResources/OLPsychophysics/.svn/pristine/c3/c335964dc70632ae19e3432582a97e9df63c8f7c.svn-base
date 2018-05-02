function OLPsychophysics
% OLBasicPupilDiamter - Runs the OneLight basic pupil diameter experiment.z
%
% What this experiment does is vary the intensity of a light of fixed
% relative spectral composition, and measure pupil diameter in repsonse.

% Set priority
%Priority(1);

% Set dbstop if error
dbstop if error;

%% Get the name of the m-file we're running.
exp.mFileName = mfilename;
exp.baseDir = fileparts(which(exp.mFileName));

% Figure out the data directory path.  The data directory should be on the
% same level as the code directory.
i = strfind(exp.baseDir, '/code');
exp.dataDir = sprintf('%sdata', exp.baseDir(1:i));

% Dynamically add the program code to the path if it isn't already on it.
if isempty(strfind(path, exp.baseDir))
    fprintf('- Adding %s dynamically to the path...', exp.mFileName);
    addpath(RemoveSVNPaths(genpath(exp.baseDir)), '-end');
    fprintf('Done\n');
end

% Grab the subversion information now.  We'll add it the 'params' variable
% later.  We do it here just in case we get an error with function which
% would cause the program to terminate.  If we did it after the experiment
% finished, we would get an error prior to saving, thus losing collected
% data.
svnInfo.(sprintf('%sSVNInfo', exp.mFileName)) = GetSVNInfo(exp.baseDir);
svnInfo.toolboxSVNInfo = GetBrainardLabStandardToolboxesSVNInfo;

%% Standard read of configuration information
[exp.configFileDir,exp.configFileName,exp.protocolDataDir,exp.protocolList,exp.protocolIndex] = GetExperimentConfigInfo(exp.baseDir,exp.mFileName,exp.dataDir);

saveDropbox = GetWithDefault('>>> Save into Dropbox folder?', 1);
if saveDropbox
    [~, userID] = system('whoami');
    userID = strtrim(userID);
    switch userID
        case {'melanopsin' 'pupillab'}
            dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
        case 'connectome'
            dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/TOME_data/'];
        otherwise
            dropboxBaseDir = ['~/Desktop/MELA_data/'];
            fprintf('\n*** User unauthorized to write into Dropbox. Saving to %s.***\n', dropboxBaseDir);
    end
    exp.protocolDataDir = fullfile(dropboxBaseDir, exp.protocolList(exp.protocolIndex).dataDirectory);
end

%% Add the config suffix 'protocols' to the 'configFileDir' field of 'exp'.
exp.configFileDir = fullfile(exp.configFileDir, 'protocols');

%% Set up data directory for this subject
[exp.subject,exp.subjectDataDir,exp.saveFileName] = GetSubjectDataDir(exp.protocolDataDir,exp.protocolList,exp.protocolIndex);
[~, exp.obsIDAndRun] = fileparts(exp.saveFileName)

%% Remind the experimenter to turn stuff on.
fprintf('- Make sure OneLight is on and ready to go\n');
fprintf('- Make sure equipment is ready to go\n');
input('> Hit return when ready to go','s');
fprintf('  - Return received.\n');

%% Store the date/time when the experiment starts.
exp.experimentTimeNow = now;
exp.experimentTimeDateString = datestr(exp.experimentTimeNow);
exp.comment{1} = GetInput('Dark adaptation duration [0, 20 mins]', 'string');
exp.comment{2} = GetInput('Artificial pupil [6 mm, 4.7 mm, none]', 'string');
exp.comment{3} = GetInput('Which eye stimulated [left eye, right eye]', 'string');
exp.comment{4} = GetInput('Dilated [yes, no]', 'string');
exp.comment{5} = GetInput('Which ND filter? [use ND notation, i.e. ND20 for 2.0 or ND00 for no filter]', 'string');
exp.comment{6} = GetInput('Which reticle? [no reticle, calibration reticle, 5 deg obscured reticle]', 'string');
exp.observerAge = GetWithDefault('Enter observer age', 32);
exp.nullingID = [];

%% Now we can execute the driver associated with this protocol.
driverCommand = sprintf('params = %s(exp);', exp.protocolList(exp.protocolIndex).driver);
eval(driverCommand);

%% Save the experimental data 'params' along with the experimental setup
% data 'exp' and the SVN info.
save(exp.saveFileName, 'params', 'exp', 'svnInfo');
fprintf('- Data saved to %s\n', exp.saveFileName);

%% Ask if we want to shutdown OL
%shutdownFlag = GetWithDefault('> Shutdown OL? (0 = no, 1 = yes)', false);
%if shutdownFlag
%    fprintf('- Shutting down OL ...\n');
%    ol = OneLight;
%    ol.shutdown;
%else
fprintf('- OL will run until shut down manually.\n');
%end