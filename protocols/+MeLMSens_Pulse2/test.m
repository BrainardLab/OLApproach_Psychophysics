%% Get projector spot
pSpot = projectorSpot.getProjectorSpot();

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

%% Validate pre
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
measurementsPre = MeLMSens_Pulse2.measureDirections(directions,oneLight,radiometer,...
                                                'primaryTolerance',1e-5,...
                                                'nMeasurements',5,...
                                                'temperatureProbe',temperatureProbe);
contrastsPre = MeLMSens_Pulse2.contrastsFromMeasurements(measurementsPre,receptors)
median(contrastsPre,2)
                                            
%% Make acquisitions
acquisitions = MeLMSens_Pulse2.makeAcquisitions(...
                directions,...
                receptors,...
                'NTrialsPerStaircase',40);
            
%% Get trialResponseSys
trialResponseSys = getTrialResponseSystem(gamePad);

%% Adjust pSpot
OLShowDirection(directions('Mel_low'),oneLight);
projectorSpot.adjust(pSpot,gamePad);

%% Run acquisitions
OLShowDirection(directions('Mel_low'),oneLight);
trialResponseSys.waitForResponse();
MeLMSens_Pulse2.runAcquisitions(acquisitions,oneLight,pSpot,trialResponseSys);

%% Validations post
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
measurementsPost = MeLMSens_Pulse2.measureDirections(directions,oneLight,radiometer,...
                                                'primaryTolerance',1e-5,...
                                                'nMeasurements',5,...
                                                'temperatureProbe',temperatureProbe);
contrastsPost = MeLMSens_Pulse2.contrastsFromMeasurements(measurementsPost,receptors)
median(contrastsPost,2)                                            