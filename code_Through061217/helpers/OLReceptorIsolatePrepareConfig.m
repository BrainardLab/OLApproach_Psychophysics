function params = OLReceptorIsolatePrepareConfig(configFileName)
% OLReceptorIsolatePrepareConfig - Creates a params struct for the receptor isolation.
%
% Syntax:
% OLReceptorIsolatePrepareConfig(configFileName)
%
% Description:
%
%
% Input:
% configFileName (string) - The name of the config file, e.g.
%     flickerconfig.cfg.  Only the simple name of the config file needs to
%     be specified.  The path to the config directory will be inferred.
%
% Use:
%   OLReceptorIsolatePrepareConfig('OLFlickerSensitivity-Background-OLEyeTrackerLongCableEyePiece1.cfg')
%
% See also:
%   OLReceptorIsolateMakeModulationNominalPrimaries, OLReceptorIsolateSaveCache
%
% 4/19/13   dhb, ms     Update for new convention for desired contrasts in routine ReceptorIsolate.
% 2/25/14   ms          Modularized.


% Setup the directories we'll use.  We count on the
% standard relative directory structure that we always
% use in our (BrainardLab) experiments.
baseDir = fileparts(fileparts(which('OLReceptorIsolatePrepareConfig')));
configDir = fullfile(baseDir, 'config', 'stimuli');
cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');

if ~isdir(cacheDir)
    mkdir(cacheDir);
end

% Make sure the config file is a fully qualified name including the parent
% path.
configFileName = fullfile(configDir, configFileName);

% Make sure the config file exists.
assert(logical(exist(configFileName, 'file')), 'OLFlickerComputeModulationSpectra:InvalidCacheFile', ...
    'Could not find config file: %s', configFileName);

% Read the config file and convert it to a struct.
cfgFile = ConfigFile(configFileName);
params = convertToStruct(cfgFile);

% Check if the cache file is active as defined in the config file. If not,
% we will not run the subsequent cache generated routines.
if ~params.isActive
    error('ERROR: Cache file not active as specified in configFile field /isActive/. Aborting.');
end

%% Calculate splatter and make plots?
params.CALCULATE_SPLATTER = true;
params.REFERENCE_OBSERVER_AGE = 32; % Age of the reference observer, w.r.t. to whom all calculations are carried out

%% Parameters
params.maxPowerDiff = 0.01;    % Max power difference between spectral bands
params.primaryHeadRoom = 0.02; % Headroom for the primaries