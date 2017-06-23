%ModulationParamsDictionary
%
% Description:
%   Generate dictionary with modulation params
%
% 6/23/17  npc  Wrote it.

function d = ModulationParamsDictionary()
    % Initialize dictionary
    d = containers.Map();
    
    %% Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment
    modulationName = 'Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment';
    params = ModulationParams();
    % Direction identifiers
    params.direction = 'LMSDirectedSuperMaxLMS';                        % Modulation direction
    params.directionCacheFile = 'Direction_LMSDirectedSuperMaxLMS.mat'; % Cache file to be used
    % Stimulation mode
    params.stimulationMode = 'maxmel';
    d(modulationName) = struct(params);
    
    %% Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment
    modulationName = 'Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment';
    params = ModulationParams();
    % Direction identifiers
    params.direction = 'MelanopsinDirectedSuperMaxMel';                         % Modulation direction
    params.directionCacheFile = 'Direction_MelanopsinDirectedSuperMaxMel.mat';  % Cache file to be used
    % Stimulation mode
    params.stimulationMode = 'maxmel';
    d(modulationName) = struct(params);
    
    %% Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment
    modulationName = 'Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment';
    params = ModulationParams();
    
    % Direction identifiers
    params.direction = 'LightFluxMaxPulse';                         % Modulation direction
    params.directionCacheFile = 'Direction_LightFluxMaxPulse.mat';  % Cache file to be used

    % Stimulation mode
    params.stimulationMode = 'maxmel';
    d(modulationName) = struct(params);
end

