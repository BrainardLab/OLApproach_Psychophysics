%%SetupPsychophysicsAppraoch  Do the protocol indpendent steps required to run a psychophysics protocol.
%
% Description:
%   Do the protocol indpendent steps required to run a protocol.  
%   These are:
%     Do the calibration
%     Make the nominal background primaries.
%     Make the nominal direction primaries.

%% Parameters
%
% Who we are
approachParams.approach = 'OLApproach_Psychophysics';

% List of all calibrations used in this approach
approachParams.calibrationTypes = {'BoxCRandomizedLongCableBEyePiece2_ND01'};%, 'BoxBRandomizedLongCableBEyePiece2_ND01'};

% List of all backgrounds used in this approach
approachParams.backgroundNames = {'LightFlux_540_380_50', 'MelanopsinDirected_275_80_667', 'LMSDirected_275_80_667',};%, 'MelanopsinDirected_275_60_667', 'LMSDirected_275_60_667', };

% List of all directions used in this approach
approachParams.directionNames = {'LightFlux_540_380_50', 'MaxMel_unipolar_275_80_667', 'MaxMel_bipolar_275_80_667', 'MaxLMS_unipolar_275_80_667',};% 'MaxMel_unipolar_275_60_667', 'MaxLMS_unipolar_275_60_667', };

%%  Make the backgrounds
for cc = 1:length(approachParams.calibrationTypes)
    tempApproachParams= approachParams;
    tempApproachParams.calibrationType = approachParams.calibrationTypes{cc};  
    OLMakeBackgroundNominalPrimaries(tempApproachParams);
end

%%  Make the directions
for cc = 1:length(approachParams.calibrationTypes)
    tempApproachParams = approachParams;
    tempApproachParams.calibrationType = approachParams.calibrationTypes{cc};  
    OLMakeDirectionNominalPrimaries(tempApproachParams,'verbose',false);
end