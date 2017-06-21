%% OLReceptorIsolateDemo.m
%
% Demos the functions which produce the receptor-isolating primary
% settings.
%
% 2/25/14       ms      Wrote it.

theDirections = {'LMDirected', 'LMinusMDirected', 'SDirected', 'MelanopsinDirected', 'RodDirected', 'MelanopsinDirectedRobust', 'OmniSilent', 'Isochromatic'};
whichReceptorsToIsolate = {[1 2] ; [1 2] ; [3] ; [4] ; [5] ; [4] ; [] ; [1 2 3 4]};
whichReceptorsToIgnore = {[5 7] ; [5 7] ; [5 6] ; [5 6 7] ; [7] ; [7] ; [] ; [5 6 7]};
modulationContrast = {[0.45 0.45], [0.1 -0.1], [0.45], [0.45], [0.05], [0.07], [], [0.45 0.45 0.45 0.45]};
receptorIsolateMode = {'Standard' ; 'Standard' ; 'Standard' ; 'Standard' ; 'Standard' ; 'Standard' ; 'EnforceSpectralChange' ; 'Standard'};

params = OLReceptorIsolatePrepareConfig('Cache-KleinSilent-OLLongCableAEyePiece1.cfg');

params.calibrationType = 'ShortCableAEyePiece1';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = true;
params.maxPowerDiff = 10^(-1.5);

for d = 7
    if d == 7
        params = OLReceptorIsolatePrepareConfig('Cache-OmniSilent-OLShortCableAEyePiece1.cfg');
    else
        
        params = OLReceptorIsolatePrepareConfig('Cache-MelanopsinDirected-OLLongCableAEyePiece1.cfg');
        
    end
    
    params.calibrationType = 'ShortCableAEyePiece1';
    params.whichReceptorsToMinimize = [];
    params.CALCULATE_SPLATTER = true;
    params.maxPowerDiff = 10^(-1.5);
    params.modulationDirection = theDirections{d};
    params.modulationContrast = modulationContrast{d};
    params.whichReceptorsToIsolate = whichReceptorsToIsolate{d};
    params.whichReceptorsToIgnore = whichReceptorsToIgnore{d};
    params.receptorIsolateMode = receptorIsolateMode{d};
    params.cacheFile = ['Cache-' theDirections{d} '.mat']
    [cacheData, olCache, params, contrastVector(:, d)] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
end

%% Klein silent
params = OLReceptorIsolatePrepareConfig('Cache-KleinSilent-OLShortCableAEyePiece1.cfg');
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = true;
params.maxPowerDiff = 10^(-1.5);

[cacheData, olCache, params] = OLReceptorIsolateMakeModulationNominalPrimaries(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
%%
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
OLValidateCacheFile(fullfile(cacheDir, ['Cache-KleinSilent.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
    1, 1, 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', 'LongCableAEyePiece1', 'CALCULATE_SPLATTER', true);    