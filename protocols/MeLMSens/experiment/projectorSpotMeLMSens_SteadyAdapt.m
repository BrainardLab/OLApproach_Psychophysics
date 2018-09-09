function pSpot = projectorSpotMeLMSens_SteadyAdapt(simulate)
%PROJECTORSPOTMELMSENS_STEADYADAPT Summary of this function goes here
%   Detailed explanation goes here
    pSpot = projectorSpot('fullScreen',~simulate);
    pSpot.addSpot('spotDiameter',110,...
                  'annulusDiameter',500);
    pSpot.show();
end