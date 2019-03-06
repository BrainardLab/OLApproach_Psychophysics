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
%                   'thresholdContrastValidated',
%                   'JNDNominal', 'JNDValidated'
%
% See also:
%    MeLMSens_Pulse.acquisition

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getAcquisitionResults
%    2019.03.06  jv   adapted for MeLMSens_SteadyAdapt


% Initialize
results = table();

% Acquisition name
results.acquisitionName = acquisition.name;

% Axis, adaptationlevel
nameParts = strsplit(acquisition.name,"_");
results.axis = nameParts(1);
results.adaptationLevel = nameParts(2);

% Quick threshold contrast
results.thresholdContrastQuick = mean(acquisition.thresholds);

% Fit threshold contrast
results.thresholdContrastFit = acquisition.fitPsychometricFunctionThreshold();

% Validated threshold contrast
results.thresholdContrastValidated = MeLMSens_SteadyAdapt.analyze.getThresholdContrastValidated(acquisition);

% L-M splatter from validation
results.LminusM = MeLMSens_SteadyAdapt.analyze.getThresholdSplatterLM(acquisition);

% Nominal JND
results.JNDNominal = MeLMSens_SteadyAdapt.analyze.getJNDQuick(acquisition);

% Fit JND
results.JNDNominal = MeLMSens_SteadyAdapt.analyze.getJNDFit(acquisition);

% Validated JND
results.JNDValidated = MeLMSens_SteadyAdapt.analyze.getJNDValidated(acquisition);
end