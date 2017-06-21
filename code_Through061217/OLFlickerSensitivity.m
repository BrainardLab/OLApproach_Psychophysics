function OLFlickerSensitivity
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

%% Standard read of configuration information
[exp.configFileDir,exp.configFileName,exp.protocolDataDir,exp.protocolList,exp.protocolIndex] = GetExperimentConfigInfo(exp.baseDir,exp.mFileName,exp.dataDir);

saveDropbox = GetWithDefault('>>> Save into Dropbox folder?', 1);
if saveDropbox
    dataPath = getpref('OneLight', 'dataPath');
    exp.protocolDataDir = fullfile(dataPath, exp.protocolList(exp.protocolIndex).dataDirectory);
end

%% Add the config suffix 'protocols' to the 'configFileDir' field of 'exp'.
exp.configFileDir = fullfile(exp.configFileDir, 'protocols');

%% Set up data directory for this subject
[exp.subject,exp.subjectDataDir,exp.saveFileName] = OLGetSubjectDataDirMR(exp.protocolDataDir,exp.protocolList,exp.protocolIndex);
[~, exp.obsIDAndRun] = fileparts(exp.saveFileName);

%% Remind the experimenter to turn stuff on.
fprintf('- Make sure OneLight is on and ready to go\n');
fprintf('- Make sure equipment is ready to go\n');
input('> Hit return when ready to go','s');
fprintf('  - Return received.\n');

%% Store the date/time when the experiment starts.
exp.experimentTimeNow = now;
exp.experimentTimeDateString = datestr(exp.experimentTimeNow);
SKIP_INFO = GetWithDefault('Skip entering subject info?', 1)
if ~SKIP_INFO
    exp.comment{1} = GetInput('Dark adaptation duration [0, 20 mins]', 'string');
    exp.comment{2} = GetInput('Artificial pupil [6 mm, 4.7 mm, none]', 'string');
    exp.comment{3} = GetInput('Which eye stimulated [left eye, right eye]', 'string');
    exp.comment{4} = GetInput('Dilated [yes, no]', 'string');
    exp.comment{5} = GetInput('Which ND filter? [use ND notation, i.e. ND20 for 2.0 or ND00 for no filter]', 'string');
    exp.comment{6} = GetInput('Which reticle? [no reticle, calibration reticle, 5 deg obscured reticle]', 'string');
    exp.comment{7} = GetInput('Any other comments?', 'string');
end

%% Now we can execute the driver associated with this protocol.
driverCommand = sprintf('params = %s(exp);', exp.protocolList(exp.protocolIndex).driver)
eval(driverCommand);

%% Save the experimental data 'params' along with the experimental setup
% data 'exp' and the SVN info.
save(exp.saveFileName, 'params', 'exp');
fprintf('- Data saved to %s\n', exp.saveFileName);

if strcmp(exp.protocolList(exp.protocolIndex).driver, 'ModulationTrialSequencePupillometryNulledOnLine');
    resp = GetWithDefault('>> Attempt to merge data?', 1);
    if resp
        pause(5);
        PupilAnalysisToolbox_MergePupilData(exp.saveFileName);
    end
end

%% Ask if we want to shutdown OL
fprintf('- OL will run until shut down manually.\n');