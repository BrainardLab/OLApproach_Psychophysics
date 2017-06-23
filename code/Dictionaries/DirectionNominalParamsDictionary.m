%DirectionNominalParamsDictionary
%
% Description:
%   Generate dictionary with params for the examined modulation directions
%
% 6/22/17  npc  Wrote it.

function d = DirectionNominalParamsDictionary()
    % Initialize dictionary
    d = containers.Map();
    
    %% MaxMel
    %
    % Note modulation contrast is typically 2/3 for 400% contrast or 66.66%
    % sinusoidal contrast, modulation contrast has been set to 20% for testing purposes
    directionName = 'MelanopsinDirected';
    params = struct();
    params.type = 'pulse';
    params.pegBackground = false;
    params.modulationDirection = {directionName};
    params.modulationContrast = [4/6];
    params.whichReceptorsToIsolate = {[4]};
    params.whichReceptorsToIgnore = {[]};
    params.whichReceptorsToMinimize = {[]};
    params.directionsYoked = [0];
    params.directionsYokedAbs = [0];
    params.receptorIsolateMode = 'Standard';
    params.backgroundType = 'BackgroundMaxMel';
    params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
    d(directionName) = params;
    
    
    %% MelanopsinDirectedSuperMaxMel
    directionName = 'MelanopsinDirectedSuperMaxMel';
    params = struct();
    params.type = 'pulse';
    params.primaryHeadRoom = 0.01;          % Original value: 0.005
    params.backgroundType = 'BackgroundMaxMel';
    params.modulationDirection = directionName;
    params.modulationContrast = [4/6];
    params.whichReceptorsToIsolate = [4];
    params.whichReceptorsToIgnore = [];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    d(directionName) = params;
    
    %% LMSdirected
    directionName = 'LMSDirected';
    params = struct();
    params.type = 'pulse';
    params.pegBackground = false;
    params.modulationDirection = {directionName};
    params.modulationContrast = {[4/6 4/6 4/6]};
    params.whichReceptorsToIsolate = {[1 2 3]};
    params.whichReceptorsToIgnore = {[]};
    params.whichReceptorsToMinimize = {[]};
    params.directionsYoked = [1];
    params.directionsYokedAbs = [0];
    params.receptorIsolateMode = 'Standard';
    params.backgroundType = 'BackgroundMaxLMS';
    params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
    d(directionName) = params;
    
    %% LMSdirectedSuperMaxMex
    directionName = 'LMSDirectedSuperMaxLMS';
    params = struct();
    params.type = 'pulse';
    params.primaryHeadRoom = 0.01;              % Original value 0.005
    params.backgroundType = 'BackgroundMaxLMS';
    params.modulationDirection = directionName;
    params.modulationContrast = [4/6 4/6 4/6];
    params.whichReceptorsToIsolate = [1 2 3];
    params.whichReceptorsToIgnore = [];
    params.whichReceptorsToMinimize = [];
    params.receptorIsolateMode = 'Standard';
    params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
    d(directionName) = params;
end