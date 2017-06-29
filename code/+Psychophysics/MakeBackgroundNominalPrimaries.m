function MakeBackgroundNominalPrimaries(approachParams)
% MakeBackgroundNominalPrimaries - Calculate the background nominal primaries
%
% Description:
%     This script calculations background nominal primaries and saves them in
%     cache files.  Typically, these are then incorporated into calculation
%     of nominal direction primaries.
%
%     The primaries depend on the calibration file. 

% 6/18/17  dhb  Added header comment.
% 6/22/17  npc  Dictionarized direction params, cleaned up.

    %% Make dictionary with direction-specific params for all directions
    paramsDictionary = BackgroundNominalParamsDictionary();
    
    %% Loop over directions
    for ii = 1:length(approachParams.backgroundNames)
        generateAndSaveBackgroundPrimaries(approachParams,paramsDictionary,approachParams.backgroundNames{ii});
    end
end

function generateAndSaveBackgroundPrimaries(approachParams, paramsDictionary, backgroundName)
    % Get background primaries
    backgroundParams = MergeBaseParamsWithParamsFromDictionaryEntry(approachParams, paramsDictionary, backgroundName);
    [cacheDataBackground, olCacheBackground] = OLReceptorIsolateMakeBackgroundNominalPrimaries(approachParams.approach,backgroundParams, true);

    % Save the background primaries in a cache file
    OLReceptorIsolateSaveCache(cacheDataBackground, olCacheBackground, backgroundParams);
  
end


