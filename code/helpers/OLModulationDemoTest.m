function OLModulationDemoTest(file)
% OLModulationDemoTest(file)
%
% Takes a modulation file and runs it.
%
% Example:
%   OLModulationDemoTest('Modulation-Isochromatic-45sWindowedDistortionProductModulation-27.mat');
%
% 5/28/15   ms  Wrote it.

% Set up some sounds
fs = 20000; durSecs = 0.1; t = linspace(0, durSecs, durSecs*fs);
yReady = sin(660*2*pi*linspace(0, 3*durSecs, 3*durSecs*fs));
yHint = [sin(880*2*pi*linspace(0, 0.1, 0.1*fs))];

% Load the file
load(file);

% Initialize the OneLight
ol = OneLight;

% Make a sound to show we're ready
sound(yReady, fs);


% Flicker starts and stops
CONTRAST_CHECK = true;
if CONTRAST_CHECK
    nValues = size(modulationObj.modulation, 3);
    for f = 1:nValues
        ol.setMirrors(modulationObj.modulation(1, 1, f).starts(1, :), modulationObj.modulation(1, 1, f).stops(1, :));
        sound(yHint, fs);
        pause;
        t = OLFlickerStartsStopsOO(ol, modulationObj.modulation(1, 1, f).starts', modulationObj.modulation(1, 1, f).stops', ...
            modulationObj.describe.params.timeStep, 1, false);
        ol.setMirrors(modulationObj.modulation(1, 1, f).starts(1, :), modulationObj.modulation(1, 1, f).stops(1, :));
    end
else
    nValues = size(modulationObj.modulation, 1);
    for f = 1:nValues
        ol.setMirrors(modulationObj.modulation(f, 1, 1).starts(1, :), modulationObj.modulation(f, 1, 1).stops(1, :));
        sound(yHint, fs);
        pause;
        while true
        t = OLFlickerStartsStopsOO(ol, modulationObj.modulation(f, 1, 1).starts', modulationObj.modulation(f, 1, 1).stops', ...
            modulationObj.describe.params.timeStep, 1, false);
        end
        ol.setMirrors(modulationObj.modulation(f, 1, 1).starts(1, :), modulationObj.modulation(f, 1, 1).stops(1, :));
    end
end
