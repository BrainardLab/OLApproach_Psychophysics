function CLUTMeasurements = measureCLUTs(pSpot, radiometer, oneLight, Mel_low, Mel_high, NRepeats)
%% Prep for measurement
% Hide macular, hide fixation
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;

%% Get CLUT
CLUT = projectorSpot.CLUT.make([.5 .5 .5],1/255,20);

%% Measure Mel_low
OLShowDirection(Mel_low,oneLight);
fprintf('Mel_Low');
CLUT_Mel_low = projectorSpot.CLUT.measure(pSpot.annulus,CLUT,radiometer, NRepeats);
for i = 1:numel(CLUT_Mel_low)
    CLUT_Mel_low(i).measurable.OLDirection = Mel_low;
end

%% Measure Mel_high
OLShowDirection(Mel_high,oneLight);
fprintf('Mel_high');
CLUT_Mel_high = projectorSpot.CLUT.measure(pSpot.annulus,CLUT,radiometer, NRepeats);
for i = 1:numel(CLUT_Mel_high)
    CLUT_Mel_high(i).measurable.OLDirection = Mel_high;
end

%% Output
CLUTMeasurements = containers.map();
CLUTMeasurements('Mel_low') = CLUT_Mel_low;
CLUTMeasurements('Mel_high') = CLUT_Mel_high;

end