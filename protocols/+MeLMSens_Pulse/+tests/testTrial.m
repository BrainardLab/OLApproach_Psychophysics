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

%% Assemble trials
tPedestal = assembleTrial(directions('Mel_low'),directions('MelStep'),directions('FlickerDirection_Mel_low'),true,.015);
tNoPedestal = assembleTrial(directions('Mel_low'),directions('MelStep'),directions('FlickerDirection_Mel_high'),false,.015);

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];
trialResponseSys = responseSystem(trialKeyBindings,[]);

%% Open connection to OL
ol = OneLight('simulate',true);

%% Display
tPedestal.run(ol,200,trialResponseSys);
tNoPedestal.run(ol,200,trialResponseSys);