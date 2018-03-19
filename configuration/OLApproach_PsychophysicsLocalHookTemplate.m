function OLApproach_PsychophysicsLocalHook
% OLApproach_PsychophysicsLocalHook - Configure things for working on OneLight projects.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by default,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute
%   tbUseProject('OLApproach_PsychophysicsLocalHook')
% to set up for this project.  You then edit your local copy to match your local machine.
%
% The main thing that this does is define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running OLApproach_Psychophysics local hook\n');
theApproach = 'OLApproach_Psychophysics';

%% Define protocols for this approach
theProtocols = DefineProtocolNames;

%% Remove old preferences
if (ispref(theApproach))
    rmpref(theApproach);
end
for pp = 1:length(theProtocols)
    if (ispref(theProtocols{pp}))
        rmpref(theProtocols{pp});
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
setpref(theApproach,'MaterialsPath',fullfile(materialsBasePath));
setpref(theApproach,'DataPath',fullfile(dataBasePath));
   
%% Set pref to point at the code for this approach
setpref(theApproach,'CodePath', fullfile(tbLocateProject(theApproach),'code'));

%% Set the calibration file path
setpref(theApproach, 'OneLightCalDataPath', fullfile(getpref(theApproach, 'MaterialsPath'), 'Experiments', theApproach, 'OneLightCalData'));
setpref('OneLightToolbox','OneLightCalData',getpref(theApproach,'OneLightCalDataPath'));

%% Prefs for individual protocols
for pp = 1:length(theProtocols)
    % Data files base path
    setpref(theProtocols{pp},'DataFilesBasePath',fullfile(getpref(theApproach, 'DataPath'),'Experiments',theApproach,theProtocols{pp}));
end

%% Set the default speak rate
setpref(theApproach, 'SpeakRateDefault', 230);

%% Add OmniDriver.jar to java path
OneLightDriverPath = tbLocateToolbox('OneLightDriver');
JavaAddToPath(fullfile(OneLightDriverPath,'xOceanOpticsJava/OmniDriver.jar'),'OmniDriver.jar');