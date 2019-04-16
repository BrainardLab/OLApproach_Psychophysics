function [CLUT_Mel_low, CLUT_Mel_high] = measureCLUTs(pSpot, radiometer, oneLight, Mel_low, Mel_high)
%%

%% Prep for measurement
% Hide macular, hide fixation
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;

%% Get CLUT
CLUT = projectorSpot.CLUT.make([.5 .5 .5],1/255,10);

%% Measure Mel_low
OLShowDirection(Mel_low,oneLight);
CLUT_Mel_low = projectorSpot.CLUT.measure(pSpot.annulus,CLUT,radiometer);

%% Measure Mel_high
OLShowDirection(Mel_high,oneLight);
CLUT_Mel_high = projectorSpot.CLUT.measure(pSpot.annulus,CLUT,radiometer);
end