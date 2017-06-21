function [photopicLuminanceCdM2 isolateContrastsSignedPositive fullOnSpd] = OLAnalyzeValidationReceptorIsolateShort(valFileNameFull)
% OLAnalyzeValidationReceptorIsolate(valFileNameFull)

[validationDir, valFileName] = fileparts(valFileNameFull);
val = LoadCalFile(valFileName, [], [validationDir '/']);

% Pull out the data for the reference observer
data = val.describe.cache.data;

% Pull out the cal ID to add to file names and titles. We can't use
% OLGetCalID since we don't necessary have the cal struct.
if isfield(val.describe, 'calID')
    calID = val.describe.calID;
    calIDTitle = val.describe.calIDTitle;
else
    calID = '';
    calIDTitle = '';
end

% Pull out S
S = val.describe.S;


theCanonicalPhotoreceptors = data(32).describe.photoreceptors;%{'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods'};
T_receptors = data(32).describe.T_receptors;%GetHumanPhotoreceptorSS(S, theCanonicalPhotoreceptors, data(val.describe.REFERENCE_OBSERVER_AGE).describe.params.fieldSizeDegrees, val.describe.REFERENCE_OBSERVER_AGE, 4.7, [], data(val.describe.REFERENCE_OBSERVER_AGE).describe.fractionBleached);

load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
photopicLuminanceCdM2 = T_xyz(2,:)*val.modulationBGMeas.meas.pr650.spectrum;
%photopicLuminanceCdM2 = [];
isolateContrastsSignedPositive = [];
fullOnSpd = val.fullOnMeas.meas.pr650.spectrum;
if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
    % Calculate the receptor activations to the background
    backgroundReceptors = T_receptors* val.modulationBGMeas.meas.pr650.spectrum;
    %% Compute and report constrasts
    differenceSpdSignedPositive = val.modulationMaxMeas.meas.pr650.spectrum-val.modulationBGMeas.meas.pr650.spectrum;
    differenceReceptors = T_receptors*differenceSpdSignedPositive;
    isolateContrastsSignedPositive = differenceReceptors ./ backgroundReceptors;
    
end