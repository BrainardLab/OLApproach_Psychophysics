function pSpot = projectorSpot(simulate)
%PROJECTORSPOTMELMSENS_STEADYADAPT Summary of this function goes here
%   Detailed explanation goes here
    pSpot = projectorSpot.projectorSpot('fullScreen',~simulate);
    pSpot.draw('spotDiameter',110,...
                  'annulusDiameter',500);
    pSpot.show();
end