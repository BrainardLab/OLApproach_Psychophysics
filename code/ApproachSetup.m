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

% Backgrounds
approachParams.backgrounds = {'MelanopsinDirected', 'LMSDirected', 'LightFlux'};

% Directions
approachParams.directions = {'MelanopsinDirectedSuperMaxMel', 'LMSDirectedSuperMaxLMS', 'LightFlux'};

