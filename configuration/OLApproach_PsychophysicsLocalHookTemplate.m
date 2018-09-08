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

%% Define Dropbox paths
dropboxPath = fullfile('~','Dropbox (Aguirre-Brainard Lab)');

% Define the following paths:
%  - materials:	[dropbox]/MELA_materials/Experiments/[Approach]
%  - data:      [dropbox]/MELA_data/Experiments/[Approach]
%  - analysis:	[dropbox]/MELA_analysis/Experiments/[Approach]
%  - cal:       [dropbox]/MELA_materials/Experiments/[Approach]/OneLightCalData
materialsBasePath = fullfile(dropboxPath,'MELA_materials','Experiments',approach);
dataBasePath = fullfile(dropboxPath,'MELA_data','Experiments',approach);
analysisBasePath = fullfile(dropboxPath,'MELA_analysis','experiments',approach);
calBasePath = fullfile(materialsBasePath,'OneLightCalData');

% Check that directories exist
assert(isdir(materialsBasePath),'Materials basepath (%s) does not exist', materialsBasePath);
assert(isdir(dataBasePath),'Data basepath (%s) does not exist', dataBasePath);
assert(isdir(calBasePath),'Calibration basepath (%s) does not exist', calBasePath);
assert(isdir(analysisBasePath),'Analysis basepath (%s) does not exist',analysisBasePath);

%% Create data symlinks
if ~unix(['test -L ',fullfile(approachPath,'data','raw')])
	delete(fullfile(approachPath,'data','raw'))
end
rawDataLinkCommand = sprintf('ln -s %s %s',...
	replace(dataBasePath,{'(',')',' '},{'\(','\)','\ '}),...
    fullfile(approachPath,'data','raw'));
system(rawDataLinkCommand);


if ~unix(['test -L ',fullfile(approachPath,'data','processed')])
    delete(fullfile(approachPath,'data','processed'))
end
procDataLinkCommand = sprintf('ln -s %s %s',...
	replace(analysisBasePath,{'(',')',' '},{'\(','\)','\ '}),...
    fullfile(approachPath,'data','processed'));
system(procDataLinkCommand);

%% Set Directory structures for individual protocols
protocols = DefineProtocolNames;
for pp = 1:length(protocols)
    protocolDir = fullfile(approachPath,'protocols',protocols{pp});
    mkdir(protocolDir,'data');
    
    rawDataDestination = fullfile(protocolDir,'data','raw');
    if ~unix(['test -L ',rawDataDestination])
        delete(rawDataDestination)
    end
    rawDataLinkCommand = sprintf('ln -s %s %s',...
        fullfile(approachPath,'data','raw',protocols{pp}),...
        rawDataDestination);
    system(rawDataLinkCommand);
    
    processedDataDestination = fullfile(protocolDir,'data','processed');
    if ~unix(['test -L ',processedDataDestination])
        delete(processedDataDestination)
    end
    processedDataLinkCommand = sprintf('ln -s %s %s',...
        fullfile(approachPath,'data','processed',protocols{pp}),...
        processedDataDestination);
    system(processedDataLinkCommand);
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
for pp = 1:length(protocols)
    if (ispref(protocols{pp}))
        rmpref(protocols{pp});
    end
    
    setpref(protocols{pp},'ProtocolBasePath',protocolDir);
    setpref(protocols{pp},'ProtocolDataRawPath',fullfile(protocolDir,'data','raw'));
    setpref(protocols{pp},'ProtocolDataProcessedPath',fullfile(protocolDir,'data','processed'));
    setpref(protocols{pp},'ProtocolExperimentPath',fullfile(protocolDir,'experiment'));
    setpref(protocols{pp},'ProtocolAnalysisPath',fullfile(protocolDir,'analysis'));
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

%% Add the symlinks to .gitignore
%     % Since on different machines, these links might not work / need to
%     % point to a different directory, the links should NOT be under source
%     % control. We add them to .gitignore to take care of that.
%     gitIgnoreFID = fopen(fullfile(getpref(approach,'CodePath'),'..','.gitignore'),'a+');
%     frewind(gitIgnoreFID);
%     gitIgnore = textscan(gitIgnoreFID,'%s','Delimiter','\n');
%     ignoreLine = fullfile('/','code','analysis',protocols{pp},'data');
%     if isempty(gitIgnore) || ~any(contains(string(gitIgnore{:}),ignoreLine))
%         fprintf(gitIgnoreFID,[ignoreLine '\n']);
%     end
%     fclose(gitIgnoreFID);