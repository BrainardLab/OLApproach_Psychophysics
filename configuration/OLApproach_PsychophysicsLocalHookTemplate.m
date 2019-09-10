function OLApproach_PsychophysicsLocalHook
% Configure paths and preferences for the OLApproach_Psychophsycis
%
% The git repository for the OLApproach defines a directory structure that
% is assumed by this script:
%   OLApproach_Psychophysics
%	??? configuration
%	??? toolbox
%	??? data
%   ?   ??? raw
%   ?   ?   ??? protocol1
%   ?   ?   ??? protocol2
%   ?   ?   ??? ...
%   ?   ??? processed
%   ?       ??? protocol1
%   ?       ??? protocol2
%   ?       ??? ...
%	??? protocols
%       ??? protocol1
%       ?   ??? experiment
%       ?   ??? analysis
%       ?   ??? data
%       ?       ??? raw
%       ?       ??? processed
%       ??? protocol2
%       ??? ...
%       ??? DefineProtocolNames.m
%
% OLApproach_Psychophysics - the toplevel domain for the approach. The path
%                            to this will be stored in
%                            pref(approach,'ApproachPath'). This is also
%                            the path returned by
%                            tbLocateProject('OLApproach_Psychophysics'))
% ./configuration          - directory for any configuration scripts,
%                            routines, etc. Contains this
%                            LocalHookTemplate. Also contains the TbTb
%                            .json configuration file
% ./toolbox                - directory containing any protocol-independent
%                            functions, scripts, utilities, etc.
% ./data                   - directory containing two symbolic links
% ./data/raw               - symlink to the data directory where ALL raw
%                            data for this approach will be stored.
%                            In the Aguirre-Brainard labs, this should
%                            point to [Dropbox]/MELA_data/Experiments/OLApproach_Psychophysics/
% ./data/processed         - symlink to the data directory where ALL
%                            processed data for this approach will be
%                            stored. In the Aguirre-Brainard labs, this
%                            should point to [Dropbox]/MELA_analysis/experiments/OLApproach_Psychophysics/
% ./protocols              - directory containing a subdirectory for each
%                            specific protocol. The ./protocols directory
%                            also contains the script
%                            DefineProtocolNames.m, which this local hook
%                            uses.
% ./protocols/protocol1/   - subdirectory for protocol 1. All files
%                            relating to that protocol should be kept here.
% .../protocol1/experiment - code/files for running the experiment, i.e.,
%                            producing the raw data.
% .../protocol1/analysis   - code/files for analyzing the data
% .../data/raw             - symlink to ./data/raw/protocol1
% .../data/processed       - synlink to ./data/processed/protocol1
%
% The protocol-specific symlinks Protocol1/data/raw and
% Protocol1/data/processed get automatically created by this script, and
% overridden if they exist.
%
% This local hook is for use with the ToolboxToolbox.  If you copy this
% into your ToolboxToolbox localToolboxHooks directory (by default,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute
%   tbUseProject('OLApproach_Psychophysics')
% to set up for this project.  You then edit your local copy to match your
% local machine.

%% Say hello
fprintf('Running OLApproach_Psychophysics local hook\n');
approach = 'OLApproach_Psychophysics';
approachPath = fullfile(tbLocateProject(approach));

%% Define paths
materialsBasePath = fullfile(approachPath,'materials');
dataBasePath = fullfile(approachPath,'data','raw');
analysisBasePath = fullfile(approachPath,'data','processed');
calBasePath = fullfile(materialsBasePath,'OneLightCalData');

% Check that directories exist
assert(isdir(materialsBasePath),'Materials basepath (%s) does not exist', materialsBasePath);
assert(isdir(dataBasePath),'Data basepath (%s) does not exist', dataBasePath);
assert(isdir(calBasePath),'Calibration basepath (%s) does not exist', calBasePath);
assert(isdir(analysisBasePath),'Analysis basepath (%s) does not exist',analysisBasePath);

%% Set raw data destination for experiment code
% Experiment (i.e., data generation code) is located in
% protocols/+[protocolName] subdirectories. We'll add a directory 'data'
% under this, where the experiment will write the raw data to. Because
% we're smart, we'll symlink this to the Approach/data/raw/[protocol]/
% directory, which itself should be a symlink to the correct Dropbox
% destination (see above)
protocols = string(DefineProtocolNames());
for protocol = protocols
    % First find out where the experiment code lives:
    experimentDir = getExperimentDir(protocol);
    experimentPath = fullfile(approachPath, experimentDir);
    
    % Deterimine path subdir 'data'
    rawDataDir = fullfile(experimentPath,'data');
    
    % Figure out the destination for the symlink, which is
    % Approach/data/raw/[protocol]
    rawDataDestination = fullfile(approachPath, 'data', 'raw', protocol);
    
    % Make symlink
    makeSymlink(rawDataDir, rawDataDestination);
end

%% Set raw data source for analysis code
% Analysis code is located in analysis/+[protocolName] subdirectories.
% We'll add a directory 'data' under this, where the experiment will read
% and write from. Under 'data/raw' it will look for raw data,.
% Because we're smart, we'll symlink this to the
% Approach/data/raw/[protocol]/ directory, which itself symlinks to the
% correct Dropbox destination (see above)
protocols = string(DefineProtocolNames());
for protocol = protocols
    % First find out where the analysis code lives:
    analysisDir = getAnalysisDir(protocol);
    analysisPath = fullfile(approachPath, analysisDir);
    
    % Deterimine path subdir 'data' 
    if ~isfolder(fullfile(analysisPath,'data'))
        mkdir(fullfile(analysisPath,'data'));
    end
    rawDataDir = fullfile(analysisPath,'data','raw');
    
    % Figure out the destination for the symlink, which is
    % Approach/data/raw/[protocol]
    rawDataDestination = fullfile(approachPath, 'data', 'raw', protocol);
    
    % Make symlink
    makeSymlink(rawDataDir, rawDataDestination);
end

%% Set processed data destination for analysis code
% Analysis code is located in analysis/+[protocolName] subdirectories.
% We'll add a directory 'data' under this, where the experiment will read
% and write from. Under 'data/processed' it will write the output of
% (intermediate) analysis. it will look for raw data,. Because we're smart,
% we'll symlink this to the Approach/data/processed/[protocol]/ directory,
% which itself symlinks to the correct Dropbox destination (see above)
protocols = string(DefineProtocolNames());
for protocol = protocols
    % First find out where the analysis code lives:
    analysisDir = getAnalysisDir(protocol);
    analysisPath = fullfile(approachPath, analysisDir);
    
    % Deterimine path subdir 'data' 
    if ~isfolder(fullfile(analysisPath,'data'))
        mkdir(fullfile(analysisPath,'data'));
    end
    processedDataDir = fullfile(analysisPath,'data','processed');
    
    % Figure out the destination for the symlink, which is
    % Approach/data/raw/[protocol]
    processedDataDestination = fullfile(approachPath, 'data', 'processed', protocol);
    
    % Make symlink
    makeSymlink(processedDataDir, processedDataDestination);
end

%% Set MATLAB preferences
% Remove old preferences
if (ispref(approach))
    rmpref(approach);
end

% Set path preferences
setpref(approach,'ApproachPath', approachPath);
setpref(approach, 'MaterialsPath', materialsBasePath);
setpref(approach, 'DataPath', dataBasePath);
setpref(approach, 'OneLightCalDataPath', calBasePath);
setpref(approach, 'AnalysisPath',analysisBasePath);

% Overwrite OneLightToolbox preference for calibrations
setpref('OneLightToolbox','OneLightCalData',getpref(approach,'OneLightCalDataPath'));

% Set protocol specific preferences
protocols = DefineProtocolNames();
for pp = 1:length(protocols)
    if (ispref(protocols{pp}))
        rmpref(protocols{pp});
    end
    
    protocolDir = fullfile(approachPath,'protocols',['+', protocols{pp}]);
    analysisDir = fullfile(approachPath,'analysis',['+', protocols{pp}]);
    
    setpref(protocols{pp},'ProtocolBasePath',protocolDir);
    setpref(protocols{pp},'ProtocolDataRawPath',fullfile(protocolDir,'data'));
    setpref(protocols{pp},'ProtocolDataProcessedPath',fullfile(analysisDir,'data','processed'));
end

%% Set simulate.
simulate.oneLight = true;
simulate.radiometer = true;
simulate.projector = true;
simulate.gamepad = true;
setpref(approach,'simulate',simulate);

%% Set the default speak rate
setpref(approach, 'SpeakRateDefault', 230);

%% Add OmniDriver.jar to java path
OneLightDriverPath = tbLocateToolbox('OneLightDriver');
JavaAddToPath(fullfile(OneLightDriverPath,'xOceanOpticsJava/OmniDriver.jar'),'OmniDriver.jar');