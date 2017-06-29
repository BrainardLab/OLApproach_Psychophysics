% ApproachSetup
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
approachParams.calibrationTypes = {'BoxDRandomizedLongCableAEyePiece2_ND02'};

% List of all backgrounds used in this approach
approachParams.backgroundNames = {'MelanopsinDirected_275_80_667', 'LMSDirected_275_80_667', 'LightFlux_540_380_50'};

% List of all directions used in this approach
approachParams.directions = {'MelanopsinDirectedSuperMaxMel', 'LMSDirectedSuperMaxLMS', 'LightFlux'};

%%  Make the backgrounds
for cc = 1:length(approachParams.calibrationTypes)
    tempApproachParams= approachParams;
    tempApproachParams.calibrationType = approachParams.calibrationTypes{cc};  
    Psychophysics.MakeBackgroundNominalPrimaries(tempApproachParams);
end



