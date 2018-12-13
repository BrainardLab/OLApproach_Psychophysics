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
backgroundWaveform = ones(1,length(flickerWaveform));

% cosine-window 0 -> 1
cosineDuration = seconds(.5);
cosineWaveform = cosineRamp(cosineDuration,samplingFq);
rampOnWaveform = [cosineWaveform, constant(seconds(.25),samplingFq)];

% cosine-window 1 -> 0
rampOffWaveform = [constant(seconds(.25),samplingFq), fliplr(cosineWaveform)];

%% Construct modulations


%% Construct trial

%% Display