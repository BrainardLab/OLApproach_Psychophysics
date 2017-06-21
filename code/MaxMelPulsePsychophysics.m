% MaxMelPulsePsychophysics
%
% Description:
%   Define the parameters for the MaxPulsePsychophysics protocol of the
%   OLApproach_Psychophysics approach, and then invoke each of the
%   functions required to set up and run the experiment.

%% Clear
clear; close all;

%% Set the parameter structure here
params.approach = 'OLApproach_Psychophysics';
params.protocol = 'MaxMelPulsePsychophysics';
%params.calType = ;

%% Make the nominal modulation primaries
Psychophysics.MakeDirectionNominalPrimaries;
