% Validate psychophysics settings
load('/Users/melanopsin/Dropbox (Aguirre-Brainard Lab)/MELA_data/PsychophysicsLMSMelanopsinHighContrastSteps/MELA_0042/stimuli/MELA_0042-PsychophysicsLMSMelanopsinHighContrastSteps-1.mat');

% Get the cal
cal = params.oneLightCal;

% Iterate through the directions
theWeights = [1 0 0 0 ; 1 1 0 0 ; 1 1 1 0 ; 1 1 -1 0 ; 1 1 0 1 ; 1 1 0 -1 ; 1 1 1 -1 ; 1 1 -1 1];

ol = OneLight;
whichMeter = 'PR-670';
meterType = 5;
S = [380 2 201];
nAverage = 1;
CMCheckInit(5);

for m = 1:length(params.basisPrimary)
    for s = 1:size(theWeights, 1)
        primaries = params.basisPrimary{m}*theWeights(s, :)';
        settings = OLPrimaryToSettings(cal, primaries);
        [starts, stops] = OLSettingsToStartsStops(cal, settings);
        
        meas = OLTakeMeasurement(ol, [], starts, stops, S, [1 0], 5, nAverage)
        
        validation{m}{s}.primaries = primaries;
        validation{m}{s}.settings = settings;
        validation{m}{s}.starts = starts;
        validation{m}{s}.stops = stops;
        validation{m}{s}.meas = meas;
    end
end

save('/Users/melanopsin/Dropbox (Aguirre-Brainard Lab)/MELA_data/PsychophysicsLMSMelanopsinHighContrastSteps/MELA_0042/stimuli/validation/MELA_0042-PsychophysicsLMSMelanopsinHighContrastSteps-1.mat', 'validation');

%%
for m= 1:3
    figure;
    plot(validation{m}{1}.meas.pr650.spectrum, '-b', 'LineWidth', 2); hold on;
    plot(validation{m}{2}.meas.pr650.spectrum, '-r', 'LineWidth', 2)
    plot(validation{m}{3}.meas.pr650.spectrum, '-k')
    plot(validation{m}{4}.meas.pr650.spectrum, '-k')
    plot(validation{m}{5}.meas.pr650.spectrum, '-k')
    plot(validation{m}{6}.meas.pr650.spectrum, '-k')
    plot(validation{m}{7}.meas.pr650.spectrum, '-k')
    plot(validation{m}{8}.meas.pr650.spectrum, '-k')
    plot(validation{m}{8}.meas.pr650.spectrum, '-k')
end