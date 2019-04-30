%% Set overall parameters
% We want to start with a clean slate, and set a number of parameters
% before doing anything else.
approach = 'OLApproach_Psychophysics';
protocol = 'MeLMSens_Pulse2';
simulate = getpref(approach,'simulate'); % localhook defines what devices to simulate

%% Set output path
participantID = GetWithDefault('>> Enter <strong>participant ID</strong>', 'HERO_xxxx');
participantAge = GetWithDefault('>> Enter <strong>participant age</strong>', 32);
sessionName = GetWithDefault('>> Enter <strong>session name</strong>:', 'session_1');
todayDate = datestr(now, 'yyyymmdd');
protocolDataPath = getpref(protocol,'ProtocolDataRawPath');
participantDataPath = fullfile(protocolDataPath,participantID);
sessionDataPath = fullfile(participantDataPath,[todayDate '_' sessionName]);
mkdir(sessionDataPath);
materialsFilename = sprintf('materials-%s-%s.mat',participantID,sessionName);

%% Get projector spot
pSpot = projectorSpot.getProjectorSpot();

%% Get calibration
calibration = getCalibration();
save(fullfile(sessionDataPath, materialsFilename),...
                'calibration','-v7.3');

%% Make directions
directions = MeLMSens_Pulse2.makeNominalOLDirections(calibration);
receptors = directions('MelStep').describe.directionParams.T_receptors;
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','receptors','-append','-v7.3');

%% Validate nominal
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
validationsNominal = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','validationsNominal','-append','-v7.3');

%% Correct
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
corrections = MeLMSens_Pulse2.correctDirections(directions,oneLight,calibration,radiometer,...
                            receptors,...
                            'smoothness',.001,...
                            'temperatureProbe',temperatureProbe);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','corrections','-append','-v7.3');

%% Validate pre
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
validationsPre = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5,...
                                                'temperatureProbe',temperatureProbe);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','validationsPre','-append','-v7.3');
                                            
%% Make acquisitions
acquisitions = MeLMSens_Pulse2.makeAcquisitions(...
                directions,...
                receptors,...
                'NTrialsPerStaircase',40);
save(fullfile(sessionDataPath,materialsFilename),...
    'acquisitions','-append','-v7.3');            

%% Get trialResponseSys
trialResponseSys = getTrialResponseSystem(gamePad);

%% Adjust pSpot
OLShowDirection(directions('Mel_low'),oneLight);
projectorSpot.adjust(pSpot,gamePad);

%% Run acquisitions
OLShowDirection(directions('Mel_low'),oneLight);
trialResponseSys.waitForResponse();
MeLMSens_Pulse2.runAcquisitions(acquisitions,oneLight,pSpot,trialResponseSys);

%% Save acquisitions
for acquisition = acquisitions(:)'    
    dataFilename = sprintf('data-%s-%s-%s.mat',participantID,sessionName,acquisition.name);
    save(fullfile(sessionDataPath,dataFilename),'acquisition','-v7.3');
end

%% Validations post
pSpot.show();
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;
validationsPost = MeLMSens_Pulse2.validateDirections(directions,oneLight,radiometer,...
                                                'receptors',receptors,...
                                                'primaryTolerance',1e-5,...
                                                'nValidations',5);
save(fullfile(sessionDataPath,materialsFilename),...
    'directions','validationsPost',...
    '-append','-v7.3');