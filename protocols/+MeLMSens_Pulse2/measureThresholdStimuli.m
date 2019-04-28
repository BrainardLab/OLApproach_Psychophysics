function thresholdStimulusMeasurements = measureThresholdStimuli(acquisitions, oneLight, pSpot, radiometer,NRepeats)
%MEASURETHRESHOLDSTIMULI Summary of this function goes here
%   Detailed explanation goes here

% Hide macular, hide fixation
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;

% Initialize
thresholdStimulusMeasurements = [];

% Loop over acquisitions
for a = acquisitions(:)
    % Set OL
    olDirection = a.background + double(a.pedestalPresent) .* a.pedestalDirection;
    OLShowDirection(olDirection, oneLight);
    
    % Figure out threshold stimuli
    thresholdDeltaRGB = a.fitPsychometricFunctionThreshold();
    thresholdRGBNeg = thresholdDeltaRGB * [-1 -1 -1] + a.flickerBackgroundRGB;
    thresholdRGBPos = thresholdDeltaRGB * [1 1 1] + a.flickerBackgroundRGB;

    % Measure
    measurementsPos = projectorSpot.measureRGB(pSpot.annulus,thresholdRGBPos,radiometer,NRepeats);
    for m = measurementsPos
       m.measurable.OLDirection = olDirection;
       m.acquisitionName = a.name;
       m.thresholdValue = thresholdDeltaRGB;
       m.direction = 'positive';
    end
    measurementsNeg = projectorSpot.measureRGB(pSpot.annulus,thresholdRGBNeg,radiometer,NRepeats);
    for m = measurementsPos
       m.measurable.OLDirection = olDirection;
       m.acquisitionName = a.name;
       m.thresholdValue = thresholdDeltaRGB;
       m.direction = 'negative';
    end    
end

end