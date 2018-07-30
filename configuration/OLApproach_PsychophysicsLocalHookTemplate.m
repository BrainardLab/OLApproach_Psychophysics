function OLApproach_PsychophysicsLocalHook
% Configure things for working on OneLight projects.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by default,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute
%   tbUseProject('OLApproach_Psychophysics')
% to set up for this project.  You then edit your local copy to match your local machine.
%
% The main thing that this does is define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running OLApproach_Psychophysics local hook\n');
approach = 'OLApproach_Psychophysics';

%% Define Dropbox path
dropboxPath = fullfile('~','Dropbox (Aguirre-Brainard Lab)');

%% Define protocols for this approach
protocols = DefineProtocolNames;

%% Remove old preferences
if (ispref(approach))
    rmpref(approach);
end
for pp = 1:length(protocols)
    if (ispref(protocols{pp}))
        rmpref(protocols{pp});
    end
end

%% Set pref to point at the code for this approach
setpref(approach,'CodePath', fullfile(tbLocateProject(approach),'code'));

%% Set Dropbox-related paths
% Define the following paths:
%  - materials:	[dropbox]/MELA_materials/Experiments/[Approach]
%  - data:      [dropbox]/MELA_data/Experiments/[Approach]
%  - analysis:	[dropbox]/MELA_analysis/Experiments/[Approach]
%  - cal:       [dropbox]/MELA_materials/Experiments/[Approach]/OneLightCalData
materialsBasePath = fullfile(dropboxPath,'MELA_materials','Experiments',approach);
dataBasePath = fullfile(dropboxPath,'MELA_data','Experiments',approach);
analysisBasePath = fullfile(dropboxPath,'MELA_analysis','Experiments',approach);
calBasePath = fullfile(materialsBasePath,'OneLightCalData');

% Check that directories exist
assert(isfolder(materialsBasePath),'Materials basepath (%s) does not exist', materialsBasePath);
assert(isfolder(dataBasePath),'Data basepath (%s) does not exist', dataBasePath);
assert(isfolder(calBasePath),'Calibration basepath (%s) does not exist', calBasePath);
assert(isfolder(analysisBasePath),'Analysis basepath (%s) does not exist',analysisBasePath);

% Set as perferences
setpref(approach, 'MaterialsPath', materialsBasePath);
setpref(approach, 'DataPath', dataBasePath); 
setpref(approach, 'OneLightCalDataPath', calBasePath);
setpref(approach, 'AnalysisPath',analysisBasePath);

% Overwrite OneLightToolbox preference for calibrations
setpref('OneLightToolbox','OneLightCalData',getpref(approach,'OneLightCalDataPath'));

%% Set Directory structures for individual protocols
for pp = 1:length(protocols)
    % Set prefs
    setpref(protocols{pp},'DataFilesBasePath',fullfile(dataBasePath,protocols{pp}));
    setpref(protocols{pp},'AnalysisBasePath',fullfile(analysisBasePath,protocols{pp}));
    
    % Create symbolic links to dropbox folders, in the
    % `analysis/[protocol]` directory. The symbolic link is a subdirectory 
    % in `analysis/[protocol]` that points directly to the dropbox 
    % directory. This makes filepath specifications in data analysis a lot
    % easier. The following links are created:
    %  - analysis/[protocol]/data/raw: MELA_data/Experiments/[Approach]/[protocol]
    %  - analysis/[protocol]/data/processed: MELA_analysis/Experiments/[Approach]/[protocol]
    protocolAnalysisDir = fullfile(getpref(approach,'CodePath'),'analysis',protocols{pp});
    mkdir(protocolAnalysisDir,'data');
    
    rawDataDestination = fullfile(protocolAnalysisDir,'data','raw');
    if ~unix(['test -L ',rawDataDestination])
        delete(rawDataDestination)
    end
    rawDataLinkCommand = sprintf('ln -s %s %s',...
        replace(getpref(protocols{pp},'DataFilesBasePath'),{'(',')',' '},{'\(','\)','\ '}),...
        rawDataDestination);
    system(rawDataLinkCommand);
    
    processedDataDestination = fullfile(protocolAnalysisDir,'data','processed');
    if ~unix(['test -L ',processedDataDestination])
        delete(processedDataDestination)
    end
    processedDataLinkCommand = sprintf('ln -s %s %s',...
        replace(getpref(protocols{pp},'AnalysisBasePath'),{'(',')',' '},{'\(','\)','\ '}),...
        processedDataDestination);
    system(processedDataLinkCommand);
    
    % Add the symlinks to .gitignore
    % Since on different machines, these links might not work / need to
    % point to a different directory, the links should NOT be under source
    % control. We add them to .gitignore to take care of that.
    gitIgnoreFID = fopen(fullfile(getpref(approach,'CodePath'),'..','.gitignore'),'a+');
    frewind(gitIgnoreFID);
    gitIgnore = textscan(gitIgnoreFID,'%s','Delimiter','\n');
    ignoreLine = fullfile('/','code','analysis',protocols{pp},'data');
    if isempty(gitIgnore) || ~any(contains(string(gitIgnore{:}),ignoreLine))
        fprintf(gitIgnoreFID,[ignoreLine '\n']);
    end
    fclose(gitIgnoreFID);
end

%% Set simulate.
simulate.oneLight = true;
simulate.radiometer = true;
simulate.projector = true;
setpref(approach,'simulate',simulate);

%% Set the default speak rate
setpref(approach, 'SpeakRateDefault', 230);

%% Add OmniDriver.jar to java path
OneLightDriverPath = tbLocateToolbox('OneLightDriver');
JavaAddToPath(fullfile(OneLightDriverPath,'xOceanOpticsJava/OmniDriver.jar'),'OmniDriver.jar');