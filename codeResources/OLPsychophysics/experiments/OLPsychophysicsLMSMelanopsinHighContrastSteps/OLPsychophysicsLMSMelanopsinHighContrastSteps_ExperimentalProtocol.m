%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run this for every subject, with 'nullingID' and 'observerAgeInYrs' adjusted for the observer.
theBaseCalTypeShort = 'BoxARandomizedLongCableBEyePiece1_ND10';
nullingID = 'MELA_GKATestND10';      % <------------- ADJUST OBSERVER ID
observerAgeInYrs = 46;              % <------------- ADJUST AGE
nullingFrequencyHz = 25; % 25 Hz

%% Determine key assignment <- ONLY RUN THIS ONCE PER SUBJECT
if rand > 0.5
    keyAssignment = 0;
else
    keyAssignment = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEMO
OLPsychophysicsLMSMelanopsinHighContrastSteps_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'demo', nullingFrequencyHz, keyAssignment);

%% SCREENING
OLPsychophysicsLMSMelanopsinHighContrastSteps_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'screening', nullingFrequencyHz, keyAssignment);

%% DARK ADAPTATION
OLDarkTimer;

%% NULLING RUN 1
OLPsychophysicsLMSMelanopsinHighContrastSteps_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'nulling', nullingFrequencyHz, keyAssignment);

%% NULLING RUN 2
OLPsychophysicsLMSMelanopsinHighContrastSteps_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'nulling', nullingFrequencyHz, keyAssignment);