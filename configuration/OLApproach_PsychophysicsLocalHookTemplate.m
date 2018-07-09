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

%% Specify base paths for materials and data
[~, userID] = system('whoami');
userID = strtrim(userID);
switch userID
    case {'melanopsin' 'pupillab'}
        materialsBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
        dataBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
    case {'dhb'}
        materialsBasePath = ['/Users1'  '/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
        dataBasePath = ['/Users1' '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];     
    case {'nicolas'}
        [~, computerName] = system('hostname');
        if (contains(computerName, 'Ithaka'))
            ABDBoxPath = '/Volumes/SamsungT3/Dropbox/AguirreBrainardLabsDropbox';
        elseif (contains(computerName, 'Manta'))
            ABDBoxPath = '/Volumes/Manta TM HD/Dropbox (Aguirre-Brainard Lab)';
        else
            error('Unknown computer name: ''%s'' !\n', computerName);
        end
        materialsBasePath = fullfile(ABDBoxPath, 'MELA_materials');
        dataBasePath = fullfile(ABDBoxPath, 'MELA_data');
    otherwise
        materialsBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
        dataBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
end

%% Set prefs for materials and data
setpref(approach,'MaterialsPath',fullfile(materialsBasePath, 'Experiments', approach));
setpref(approach,'DataPath',fullfile(dataBasePath, 'Experiments', approach));
   
%% Set pref to point at the code for this approach
setpref(approach,'CodePath', fullfile(tbLocateProject(approach),'code'));

%% Set the calibration file path
setpref(approach, 'OneLightCalDataPath', fullfile(getpref(approach, 'MaterialsPath'), 'OneLightCalData'));
setpref('OneLightToolbox','OneLightCalData',getpref(approach,'OneLightCalDataPath'));

%% Prefs for individual protocols
for pp = 1:length(protocols)
    % Data files base path
    setpref(protocols{pp},'DataFilesBasePath',fullfile(getpref(approach, 'DataPath'),protocols{pp}));
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