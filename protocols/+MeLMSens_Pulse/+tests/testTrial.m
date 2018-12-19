%%
import('MeLMSens_Pulse.*');

%% Set up directions
% Background Mel_low
% pulse direction Mel_Step
% flicker direction FlickerDirection_Mel_low
% flicker direction FlickerDirection_Mel_high

% Get calibration
calibration = getCalibration();

% Make directions
directions = makeNominalDirections(calibration);

%% Set up waveforms
samplingFq = 200; % Hz

% sinusoid
flickerFrequency = 5; % Hz
flickerDuration = seconds(.5);
flickerWaveform = sinewave(flickerDuration,samplingFq,flickerFrequency);

% constant at 1
referenceWaveform = ones(1,length(flickerWaveform));

% cosine-window 0 -> 1
cosineDuration = seconds(.5);
cosineWaveform = cosineRamp(cosineDuration,samplingFq);
rampOnWaveform = [cosineWaveform, constant(seconds(.25),samplingFq)];

% cosine-window 1 -> 0
rampOffWaveform = [constant(seconds(.25),samplingFq), fliplr(cosineWaveform)];

%% Scale direction to contrast
receptors = directions('MelStep').describe.directionParams.T_receptors;
flickerContrast = .015;
flickerDirection = directions('FlickerDirection_Mel_high');
scaledDirection = flickerDirection.ScaleToReceptorContrast(directions('Mel_high'), receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);

%% Construct modulations
preModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep')],[constant(seconds(.75),samplingFq); rampOnWaveform]);
postModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep')],[constant(seconds(.75),samplingFq); rampOffWaveform]);
referenceModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep')],[referenceWaveform; referenceWaveform]);
interstimulusModulation = referenceModulation;

targetModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep') scaledDirection],[referenceWaveform; referenceWaveform; flickerWaveform]);

%% Construct trial
t = Trial_NIFC(2,targetModulation,referenceModulation);
t.interstimulusModulation = interstimulusModulation;
t.preModulation = preModulation;
t.postModulation = postModulation;
t.initialize();

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];
trialResponseSys = responseSystem(trialKeyBindings,[]);

%% Display
ol = OneLight('simulate',true);
t.run(ol,samplingFq,trialResponseSys);