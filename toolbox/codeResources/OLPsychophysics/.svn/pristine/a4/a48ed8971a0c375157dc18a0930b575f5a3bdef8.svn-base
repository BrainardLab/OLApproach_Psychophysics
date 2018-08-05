function OLPsychophysicsLMSMelanopsinHighContrastSteps_DoNulling(nullingID, observerAgeInYrs, theBaseCalTypeShort, modType, nullingFrequencyHz, keyAssignment)
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, modType, nullingFrequencyHz)
%
% 9/24/15   ms  Wrote it as a wrapper.

if isempty(nullingFrequencyHz)
    nullingFrequencyHz = 25; % Hz
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract some parameters
theCalTypeNulling = ['OL' theBaseCalTypeShort];
clc;

% Select the protocol
availableProtocols = {'OLPsychophysicsNulling'};
keepPrompting = true;
while keepPrompting
    % Show the available cache types.
    fprintf('\n*** Available protocols: ***\n\n');
    for i = 1:length(availableProtocols)
        fprintf('%d - %s\n', i, availableProtocols{i});
    end
    fprintf('\n');
    
    protocolIndex = GetInput('Select the protocol', 'number', 1);
    
    % Check the selection.
    if protocolIndex >= 1 && protocolIndex <= length(availableProtocols)
        keepPrompting = false;
    else
        fprintf('\n* Invalid selection\n');
    end
end
whichProtocol = availableProtocols{protocolIndex};

switch modType
    case 'demo'
        %% Training
        fprintf('*** STARTING DEMO ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, true, modType, keyAssignment, whichProtocol);
    case 'screening'
        %% Screening
        fprintf('*** STARTING SCREENING ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, true, modType, keyAssignment, whichProtocol);
    case 'nulling'
        %% Nulling
        fprintf('*** STARTING NULLING ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, true, modType, keyAssignment, whichProtocol);
    case 'validation'
        OLFlickerNulling_Validate(nullingID, whichProtocol);
end