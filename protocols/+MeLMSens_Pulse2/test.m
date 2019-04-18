%% Get projector spot
pSpot = projectorSpot.getProjectorSpot();

%% Get calibration
calibration = getCalibration();

%% Make directions
directions = MeLMSens_Pulse2.makeNominalOLDirections(calibration);

%% Setup acquisition
acquisition = MeLMSens_Pulse2.Acquisition();
acquisition.background = directions('Mel_low');
acquisition.pedestalDirection = directions('MelStep');
acquisition.pedestalPresent = 1;
acquisition.makeModulations();
acquisition.staircase = MeLMSens_Pulse2.makeStaircase();

%% Dummy stimulus
dummyStim = acquisition.dummyStimulus();

dummyStim.show(oneLight,pSpot);