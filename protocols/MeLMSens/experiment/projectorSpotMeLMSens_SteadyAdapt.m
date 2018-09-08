function pSpot = projectorSpotMeLMSens_SteadyAdapt(simulate)
%PROJECTORSPOTMELMSENS_STEADYADAPT Summary of this function goes here
%   Detailed explanation goes here
    pSpot = projectorSpot('fullScreen',~simulate);
    pSpot.addSpot('spotDiameter',160,...
                  'annulusDiameter',530);
end