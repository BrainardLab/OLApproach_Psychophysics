function OLApproach_PsychophysicsEngine(OL, protocolParams, varargin)
%OLAPPROACH_PSYCHOPHYSICSENGINE Run an OLApproach_Psychophysics protocol
%experiment
%
% Usage:
%   OLApproach_PsychophysicsEngine(OneLightObject,protocolParams)
%
% Description:
%   Master program for running psychophysics experiment protocol using
%   OneLight stimuli. For running fMRI experiments with the OneLight, see
%   OLApproach_TrialSequenceMR
%
% Input:
%   OL (object)             An open OneLight object
%   protocolParams (struct) Structure defining protocol parameters
%
% Output:
%   None.
%
% Optional key/value pairs:
%   verbose (logical)       true    Be chatty?
%

%% Parse arguments
p = inputParser;
p.addParameter('verbose',true,@islogical);
p.parse(varargin{:});

protocolParamsParser = inputParser;
protocolParamsParser.addRequired('protocol');
protocolParamsParser.addRequired('observerID');
protocolParamsParser.addRequired('todayDate');
protocolParamsParser.addRequired('sessionName');
protocolParamsParser.parse(protocolParams)
protocolParams = protocolParams.Results;

%% Where the data goes
savePath = fullfile(getpref(protocolParams.protocol, 'DataFilesBasePath'),protocolParams.observerID, protocolParams.todayDate, protocolParams.sessionName);
if ~exist(savePath,'dir')
    mkdir(savePath);
end

%% Start session log

%% Begin the experiment

%% Set the background

%% Adapt to background

%% Set up for responses
if (p.Results.verbose), fprintf('Creating keyboard listener\n'); end
mglListener('init');

%% Run the trial loop

%% Turn off key listener
mglListener('quit');

%% Save the data

%% Close session log

end

