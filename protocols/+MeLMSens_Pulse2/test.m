%% Get projector spot
pSpot = projectorSpot.getProjectorSpot();

%% Get calibration
calibration = getCalibration();

%% Make directions
directions = MeLMSens_Pulse2.makeNominalOLDirections(calibration);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Validate nominal
pSpot.hide();
validationsNominal = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);

%% Correct
pSpot.hide();
corrections = MeLMSens_Pulse2.correctDirections(directions,oneLight,calibration,radiometer,...
                            receptors,...
                            'smoothness',.001,...
                            'temperatureProbe',temperatureProbe);

%% Validate pre
pSpot.hide();
validationsPre = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);

%% Make acquisitions
acquisitions = MeLMSens_Pulse2.makeAcquisitions(...
                directions,...
                receptors,...
                'NTrialsPerStaircase',3);

%% Get trialResponseSys
trialResponseSys = getTrialResponseSystem(gamePad);

%% Run acquisitions
trialResponseSys.waitForResponse();
MeLMSens_Pulse2.runAcquisitions(acquisitions,oneLight,pSpot,trialResponseSys);

%% Validations post
pSpot.hide();
validationsPost = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);
                                            
%% Measure projector CLUT post
NRepeats = 5;
pSpot.show();
for a = acquisitions
    a.measureProjectorCLUT(pSpot, oneLight, radiometer, NRepeats)
end