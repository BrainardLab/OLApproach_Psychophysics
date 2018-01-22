function DemoEngine(trialList,ol,protocolParams,varargin)
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
p.addParameter('verbose',true,@islogical);
p.parse;

%% Speaking rate
speakRateDefault = getpref(protocolParams.approach, 'SpeakRateDefault');

%% Run trialList

% Wait for button press
Speak('Press key to start demo', [], speakRateDefault);
if (~protocolParams.simulate.oneLight), WaitForKeyPress; end

fprintf('<strong>Demo started</strong>\n');
for trialNum = 1:numel(trialList)
    trial = trialList(trialNum);
    fprintf('Stimulus: <strong>%s</strong>\n', trial.directionName);
    
    % Adapt to background for 1 minute
    ol.setMirrors(trial.backgroundStarts, trial.backgroundStops);
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', protocolParams.AdaptTimeSecs), [], speakRateDefault);
    if (~protocolParams.simulate.oneLight), WaitForKeyPress; end
    fprintf('Adapting...'); Speak('Adaptation started.', [], speakRateDefault);
    mglWaitSecs(protocolParams.AdaptTimeSecs);
    Speak('Adaptation complete', [], speakRateDefault);
    fprintf('Done.\n');
    
    % Show N repeats of stimulus
    for R = 1:protocolParams.nRepeatsPerStimulus
        ol.setMirrors(trial.backgroundStarts, trial.backgroundStops);

        fprintf('Repeat: <strong>%g</strong>\n', R);
        Speak('Press key to start.', [], 200);
        if (~protocolParams.simulate.oneLight), WaitForKeyPress; end
        
        fprintf('Showing stimulus...'); Speak('Showing stimulus.',[], speakRateDefault);
        OLFlicker(ol, trial.modulationStarts, trial.modulationStops, trial.timestep, 1);
        fprintf('Done.\n')
    end
end

%% Inform user that we are done
Speak('End of demo.', [], speakRateDefault);