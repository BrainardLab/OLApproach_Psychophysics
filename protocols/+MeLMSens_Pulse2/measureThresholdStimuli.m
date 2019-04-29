function measurementsThreshold = measureThresholdStimuli(acquisition, oneLight, pSpot, radiometer,NRepeats)
%MEASURETHRESHOLDSTIMULI Summary of this function goes here
%   Detailed explanation goes here

% Hide macular, hide fixation
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;

% Set OL
olDirection = acquisition.background + double(acquisition.pedestalPresent) .* acquisition.pedestalDirection;
OLShowDirection(olDirection, oneLight);

% Figure out threshold stimuli
thresholdStep = acquisition.fitPsychometricFunctionThreshold();
thresholdDeltaRGB = 1/255 * [1 1 1] * thresholdStep;
thresholdRGBNeg = -thresholdDeltaRGB + acquisition.flickerBackgroundRGB;
thresholdRGBPos = +thresholdDeltaRGB + acquisition.flickerBackgroundRGB;

% Measure background
measurementsBackground = projectorSpot.measureRGB(pSpot.annulus,acquisition.flickerBackgroundRGB,radiometer,NRepeats);
for i = 1:numel(measurementsBackground)
   measurementsBackground(i).measurable.OLDirection = olDirection;
   measurementsBackground(i).acquisitionName = acquisition.name;
   measurementsBackground(i).thresholdValue = 0;
   measurementsBackground(i).direction = 'background';
end

% Measure positive arm
measurementsThresholdPos = projectorSpot.measureRGB(pSpot.annulus,thresholdRGBPos,radiometer,NRepeats);
for i = 1:numel(measurementsThresholdPos)
   measurementsThresholdPos(i).measurable.OLDirection = olDirection;
   measurementsThresholdPos(i).acquisitionName = acquisition.name;
   measurementsThresholdPos(i).thresholdValue = thresholdStep;
   measurementsThresholdPos(i).direction = 'positive';
end

% Measure negative arm
measurementsThresholdNeg = projectorSpot.measureRGB(pSpot.annulus,thresholdRGBNeg,radiometer,NRepeats);
for i = 1:numel(measurementsThresholdNeg)
   measurementsThresholdNeg(i).measurable.OLDirection = olDirection;
   measurementsThresholdNeg(i).acquisitionName = acquisition.name;
   measurementsThresholdNeg(i).thresholdValue = thresholdStep;
   measurementsThresholdNeg(i).direction = 'negative';
end  

measurementsThreshold = containers.Map();
measurementsThreshold('Background') = measurementsBackground;
measurementsThreshold('Positive') = measurementsThresholdPos;
measurementsThreshold('Negative') = measurementsThresholdNeg;

end