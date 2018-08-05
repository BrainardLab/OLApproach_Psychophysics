function DemoEngine(trialList,oneLight,varargin)
%%Demo  Simple program for demo of pulses
%
% Description:
%    Simple program for demo of pulses
%
% Optional key/value pairs:
%    verbose (logical)         true       Be chatty?

% 7/7/16    ms      Wrote it.
% 7/28/17   dhb     Pass ol object

%% Parse
p = inputParser;
p.addRequired('trialList');
p.addRequired('oneLight',@(x) isa(x,'OneLight'));
p.addParameter('verbose',true,@islogical);
p.addParameter('speakRate',320,@isscalar);
p.parse(trialList, oneLight, varargin{:});

speakRate = p.Results.speakRate;

%% Run trialList

% Wait for button press
Speak('Press key to start demo', [], speakRate);
if (~oneLight.Simulate), commandwindow; WaitForKeyPress; end

fprintf('<strong>Demo started</strong>\n');
for trialNum = 1:numel(trialList)
    trial = trialList(trialNum);
    fprintf('Stimulus: <strong>%s</strong>\n', trial.name);
    
    % Adapt to background for 1 minute
    oneLight.setMirrors(trial.backgroundStarts, trial.backgroundStops);
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', trial.adaptTime), [], speakRate);
    if (~oneLight.Simulate), commandwindow; WaitForKeyPress; end
    fprintf('Adapting...'); Speak('Adaptation started.', [], speakRate);
    mglWaitSecs(trial.adaptTime);
    Speak('Adaptation complete', [], speakRate);
    fprintf('Done.\n');
    
    % Show N repeats of stimulus
    for R = 1:trial.repeats
        oneLight.setMirrors(trial.backgroundStarts, trial.backgroundStops);

        fprintf('Repeat: <strong>%g</strong>\n', R);
        Speak('Press key to start.', [], 200);
        if (~oneLight.Simulate), commandwindow; WaitForKeyPress; end
        
        fprintf('Showing stimulus...'); Speak('Showing stimulus.',[], speakRate);
        OLFlicker(oneLight, trial.modulationStarts, trial.modulationStops, trial.timestep, 1);
        fprintf('Done.\n')
    end
end

%% Inform user that we are done
Speak('End of demo.', [], speakRate);