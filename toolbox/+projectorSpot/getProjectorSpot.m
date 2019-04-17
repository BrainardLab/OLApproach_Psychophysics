function pSpot = getProjectorSpot()
%GETPROJECTORSPOT Summary of this function goes here
%   Detailed explanation goes here

%% Open window
simulate = getpref('OLApproach_Psychophysics','simulate');
wdw = projectorSpot.getWindow('FullScreen',~simulate.projector);

%% Open projector spot
pSpot = projectorSpot.projectorSpot('window',wdw);
pSpot.show();
end