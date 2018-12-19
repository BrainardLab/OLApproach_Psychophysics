function trial = assembleTrial(directions, stepPresent,flickerContrast)
% Parametrically assemble a trial in this protocol

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
if stepPresent
    flickerDirection = directions('FlickerDirection_Mel_high');
    backgroundDirection = directions('Mel_high');
else
    flickerDirection = directions('FlickerDirection_Mel_low');
    backgroundDirection = directions('Mel_low');
end
scaledDirection = flickerDirection.ScaleToReceptorContrast(backgroundDirection, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);

%% Construct modulations
if stepPresent
    preModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep')],[constant(seconds(.75),samplingFq); rampOnWaveform]);
    postModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep')],[constant(seconds(.75),samplingFq); rampOffWaveform]);
    referenceModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep')],[referenceWaveform; referenceWaveform]);
    interstimulusModulation = referenceModulation;
    targetModulation = OLAssembleModulation([directions('Mel_low') directions('MelStep') scaledDirection],[referenceWaveform; referenceWaveform; flickerWaveform]);
else
    preModulation = OLAssembleModulation(directions('Mel_low'),...
        constant(seconds(.75),samplingFq));
    postModulation = preModulation;
    referenceModulation = OLAssembleModulation(directions('Mel_low'),...
        referenceWaveform);
    interstimulusModulation = referenceModulation;
    targetModulation = OLAssembleModulation([directions('Mel_low') scaledDirection],...
        [referenceWaveform; flickerWaveform]);
end

%% Construct trial
trial = Trial_NIFC(2,targetModulation,referenceModulation);
trial.interstimulusModulation = interstimulusModulation;
trial.preModulation = preModulation;
trial.postModulation = postModulation;
trial.initialize();
end