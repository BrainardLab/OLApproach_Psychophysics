function trialResponseSystem = getTrialResponseSystem(gamePad)
%GETRESPONSESYSTEM Summary of this function goes here
%   Detailed explanation goes here

trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('GP:B') = 'abort';
trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
trialKeyBindings('GP:UPPERLEFTTRIGGER') = [1 0];
trialKeyBindings('GP:UPPERRIGHTTRIGGER') = [0 1];  
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];

trialResponseSystem = responseSystem(trialKeyBindings,gamePad);
end