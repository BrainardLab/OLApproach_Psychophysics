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

%% Extract receptors
receptors = directions('FlickerDirection_Mel_low').describe.directionParams.T_receptors;

%% Make acquisition
acquisition_pedestal = acquisition(...
    directions('Mel_low'),...
    directions('MelStep'), true,...
    directions('FlickerDirection_Mel_high'),...
    receptors,...
    'name',"Pedestal");

acquisition_nopedestal = acquisition(...
    directions('Mel_low'),...
    directions('MelStep'), false,...
    directions('FlickerDirection_Mel_low'),...
    receptors,...
    'name',"NoPedestal");

%% Initialize
acquisition_pedestal.initializeStaircases();
acquisition_nopedestal.initializeStaircases();

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];
trialResponseSys = responseSystem(trialKeyBindings,[]);

%% Open OL connection
oneLight = OneLight('simulate',true);

%% Try
assert(acquisition_pedestal.hasNextTrial());
assert(acquisition_nopedestal.hasNextTrial());
[correct, abort] = acquisition_pedestal.runNextTrial(oneLight, trialResponseSys)
[correct, abort] = acquisition_nopedestal.runNextTrial(oneLight, trialResponseSys)

assert(sum(acquisition_pedestal.nTrialsRemaining) == 119);
assert(sum(acquisition_nopedestal.nTrialsRemaining) == 119);