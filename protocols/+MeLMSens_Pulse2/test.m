%% Get projector spot
pSpot = projectorSpot.getProjectorSpot();

%% Get calibration
calibration = getCalibration();

%% Make directions
directions = MeLMSens_Pulse2.makeNominalOLDirections(calibration);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Validate nominal
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
validationsNominal = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);

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
validationsPre = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);
                                            
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
validationsPost = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);