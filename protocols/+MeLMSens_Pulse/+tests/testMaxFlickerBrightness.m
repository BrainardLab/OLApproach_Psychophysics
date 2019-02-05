function testMaxFlickerBrightness(oneLight)
import('MeLMSens_Pulse.*');
simulate = getpref('OLApproach_Psychophysics','simulate'); % localhook defines what devices to simulate

%% Get calibration
calibration = getCalibration();

%% Get projectorSpot
pSpot = projectorSpot(simulate.projector);

%% Make directions
directions = makeNominalDirections(calibration,'observerAge',32);
receptors = directions('MelStep').describe.directionParams.T_receptors;

%% Set trial response system
trialKeyBindings = containers.Map();
trialKeyBindings('ESCAPE') = 'abort';
trialKeyBindings('Q') = [1 0];
trialKeyBindings('P') = [0 1];

if ~simulate.gamepad
    gamePad = GamePad();
    trialKeyBindings('GP:B') = 'abort';
    trialKeyBindings('GP:UPPERLEFTTRIGGER') = [1 0];
    trialKeyBindings('GP:UPPERRIGHTTRIGGER') = [0 1];    
    trialKeyBindings('GP:LOWERLEFTTRIGGER') = [1 0];
    trialKeyBindings('GP:LOWERRIGHTTRIGGER') = [0 1];
else
    gamePad = [];
end
trialResponseSys = responseSystem(trialKeyBindings,gamePad);

%% Show
flickerContrast = .05;
trialResponseSys.waitForResponse();
while true
    background = directions('Mel_high');
    OLShowDirection(background, oneLight);
    flickerModulation = flickerModulationAtContrast(directions, receptors, flickerContrast);
    
    Beeper;
    OLFlicker(oneLight, flickerModulation.starts, flickerModulation.stops, 1/200, 1);
    
    response = trialResponseSys.waitForResponse();   
    if any(strcmpi(response,'abort'))
        % User wants to abort
        return
    end
    
    change = sum(response{:} .* [-1 1])*.01;
    flickerContrast = flickerContrast + change;
    flickerContrast = max(0,min(flickerContrast,.05))
end

end

function targetModulation = flickerModulationAtContrast(directions, receptors, flickerContrast)
%% Create modulation at target contrast
% Set up waveforms
samplingFq = 200; % Hz

% sinusoid
flickerFrequency = 5; % Hz
flickerDuration = seconds(.5);
flickerWaveform = sinewave(flickerDuration,samplingFq,flickerFrequency);

% constant at 1
referenceWaveform = ones(1,length(flickerWaveform));

% Scale direction to contrast
flickerDirection = directions('FlickerDirection_Mel_high');
background = directions('Mel_high');
scaledDirection = flickerDirection.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);

targetModulation = OLAssembleModulation([background scaledDirection],...
        [referenceWaveform; flickerWaveform]);
end