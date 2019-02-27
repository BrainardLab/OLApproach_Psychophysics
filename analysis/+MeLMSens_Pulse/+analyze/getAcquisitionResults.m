function results = getAcquisitionResults(acquisition)
% Extract results from acquisition
%   
% Syntax:
%   resultsTable = getThresholdContrastValidated(acquisition)
%
% Description:
%    From a completed MeLMSens_Pulse.acquisition, extract the nominal and
%    validated LMS threshold contrast.
%   
% Inputs:
%    acquisition  - scalar MeLMSense_Pulse_acquisition
%
% Outputs:
%    resultsTable - table(), with variables 'name', 'pedestalPresent',
%                   'thresholdContrastNominal',
%
% See also:
%    MeLMSens_Pulse.acquisition

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getAcquisitionResults

% Initialize
results = table();

% Acquisition name
results.name = acquisition.name;

% Pedestal?
results.pedestal = acquisition.pedestalPresent;

% Nominal threshold contrast
results.thresholdContrastNominal = acquisition.threshold;

end