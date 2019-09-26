%% Get projector spot
pSpot = projectorSpot.getProjectorSpot();
pSpot.annulus.RGB = [.5 .5 .5];
pSpot.show()

%% Get calibration
calibration = getCalibration();

%% Make directions
directions = MeLMSens_Pulse2.makeNominalOLDirections(calibration);
receptors = directions('MelStep').describe.directionParams.T_receptors;
nominalContrasts = nominalReceptorContrastDirections(directions('Mel_low'),directions('Mel_high'),receptors)

%% Validate nominal
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
measurementsNominal = MeLMSens_Pulse2.measureDirections(directions,oneLight,radiometer,...
    'primaryTolerance',1e-5,...
    'nMeasurements',5,...
    'temperatureProbe',temperatureProbe);
contrastsNominal = MeLMSens_Pulse2.contrastsFromMeasurements(measurementsNominal,receptors)
median(contrastsNominal,2)

%% Correct
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
corrections = MeLMSens_Pulse2.correctDirections(directions,oneLight,calibration,radiometer,...
    receptors,...
    'smoothness',.001,...
    'temperatureProbe',temperatureProbe);

%% Validations post correction
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
measurementsPost = MeLMSens_Pulse2.measureDirections(directions,oneLight,radiometer,...
    'primaryTolerance',1e-5,...
    'nMeasurements',5,...
    'temperatureProbe',temperatureProbe);
contrastsPost = MeLMSens_Pulse2.contrastsFromMeasurements(measurementsPost,receptors)
median(contrastsPost,2)

%% Extract directions
Mel_low = directions('Mel_low');
Mel_high = directions('Mel_high');

%% Measure pSpot delta RGB levels
% we'll repeat for some high N:
nRepeats = 20;

% We're going to measure the projector stimulus at some fixed levels,
% defined in delta-RGB:
measureDeltas = [64]/255;

for d = measureDeltas
    % We'll measure the pSpot at backgroundRGB +- measureDeltas
    RGBPos = [.5 .5 .5] + d;
    RGBNeg = [.5 .5 .5] - d;
    
    % Set pSpot in correct state:
    pSpot.show();
    pSpot.macular.Visible = false;
    pSpot.fixation.Visible = false;
    
    % Measure on Mel_low
    Mel_low.OLShowDirection(oneLight);
    measurementsLowPos = projectorSpot.measureRGB(pSpot.annulus,RGBPos,radiometer,nRepeats);
    measurementsLowNeg = projectorSpot.measureRGB(pSpot.annulus,RGBNeg,radiometer,nRepeats);
    
    % Measure on Mel_high
    Mel_high.OLShowDirection(oneLight);
    measurementsHighPos = projectorSpot.measureRGB(pSpot.annulus,RGBPos,radiometer,nRepeats);
    measurementsHighNeg = projectorSpot.measureRGB(pSpot.annulus,RGBNeg,radiometer,nRepeats);
end