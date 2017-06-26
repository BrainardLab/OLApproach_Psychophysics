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

%% Remove old preferences
if (ispref(theApproach))
    rmpref(theApproach);
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
        materialsBasePath = '/Volumes/Manta TM HD/Dropbox (Aguirre-Brainard Lab)/MELA_materials';
        dataBasePath = '/Volumes/Manta TM HD/Dropbox (Aguirre-Brainard Lab)/MELA_data';
    otherwise
        materialsBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_materials'];
        dataBasePath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
end

%% Set prefs for materials and data
setpref(theApproach,'MaterialsPath',fullfile(materialsBasePath));
setpref(theApproach,'DataPath',fullfile(dataBasePath));
   
%% Set pref to point at the code for this approach
setpref(theApproach, 'CodePath', fullfile(tbLocateProject(theApproach),'code'));

%% Set the calibration file path
setpref(theApproach, 'OneLightCalDataPath', fullfile(getpref(theApproach, 'MaterialsPath'), 'OneLightCalData'));

%% Set the direction nominal primaries path
setpref(theApproach,'DirectionNominalPrimariesPath',fullfile(getpref(theApproach, 'MaterialsPath'),'Experiments',theApproach,'DirectionNominalPrimaries'));

% Set the spectrum sought primaries base path
setpref(theApproach,'DirectionCorrectedPrimariesBasePath',fullfile(getpref(theApproach, 'DataPath'),'Experiments',theApproach,'DirectionCorrectedPrimaries'));

% Set the validation base path
setpref(theApproach,'DirectionCorrectedPrimariesBasePath',fullfile(getpref(theApproach, 'DataPath'),'Experiments',theApproach,'DirectionValidationFiles'));

% Modulation configuration files path
setpref(theApproach,'ModulationConfigPath',fullfile(tbLocateProject(theApproach),'modulationconfig'));

% Modulation starts/stops files base path
setpref(theApproach,'ModulationStartsStopsBasePath',fullfile(getpref(theApproach, 'DataPath'),'Experiments',theApproach,'ModulationStartsStops'));

%% Set the default speak rate
setpref(theApproach, 'SpeakRateDefault', 230);

%% Add OmniDriver.jar to java path
OneLightDriverPath = tbLocateToolbox('OneLightDriver');
JavaAddToPath(fullfile(OneLightDriverPath,'xOceanOpticsJava/OmniDriver.jar'),'OmniDriver.jar');
