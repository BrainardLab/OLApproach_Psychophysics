function trial = assembleTrial(background, pedestalDirection, flickerDirection, stepPresent,flickerContrast)
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
receptors = pedestalDirection.describe.directionParams.T_receptors;
scaledDirection = flickerDirection.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);

%% Construct modulations
if stepPresent
    preModulation = OLAssembleModulation([background pedestalDirection],[constant(seconds(.75),samplingFq); rampOnWaveform]);
    postModulation = OLAssembleModulation([background pedestalDirection],[constant(seconds(.75),samplingFq); rampOffWaveform]);
    referenceModulation = OLAssembleModulation([background pedestalDirection],[referenceWaveform; referenceWaveform]);
    interstimulusModulation = referenceModulation;
    targetModulation = OLAssembleModulation([background pedestalDirection scaledDirection],[referenceWaveform; referenceWaveform; flickerWaveform]);
else
    preModulation = OLAssembleModulation(background,...
        constant(seconds(.75),samplingFq));
    postModulation = preModulation;
    referenceModulation = OLAssembleModulation(background,...
        referenceWaveform);
    interstimulusModulation = referenceModulation;
    targetModulation = OLAssembleModulation([background scaledDirection],...
        [referenceWaveform; flickerWaveform]);
end

%% Construct trial
trial = Trial_NIFC(2,targetModulation,referenceModulation);
trial.interstimulusModulation = interstimulusModulation;
trial.preModulation = preModulation;
trial.postModulation = postModulation;
trial.initialize();
end