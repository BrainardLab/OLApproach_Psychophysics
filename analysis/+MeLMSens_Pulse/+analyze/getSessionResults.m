function resultsTable = getSessionResults(session)
% Extract results from all acquisitions in a session
%   
% Syntax:
%   resultsTable = getSessionResults(session)
%
% Description:
%    From a set of completed MeLMSens_Pulse.acquisition, extract the
%    nominal and validated LMS threshold contrast.
%   
% Inputs:
%    acquisition  - containers.Map with MeLMSens_Pulse.acquisition(s)
%
% Outputs:
%    resultsTable - table(), with variables 'name', 'pedestalPresent',
%                   'thresholdContrastNominal',
%                   'thresholdContrastValidated'
%
% See also:
%    MeLMSens_Pulse.acquisition,
%    MeLMSens_Pulse.analyze.getAcquisitionResults

% History:
%    2018.10.26  jv   wrote MeLMSens_SteadyAdapt.
%                     extractResultsFromAcquisition with collection
%                     of subfunctions
%    2019.02.27  jv   wrote MeLMSens_Pulse. analyze. getSessionResults

% Initialize
resultsTable = table();

% Loop over acquisitions
for acquisition = session.values
    T = MeLMSens_Pulse.analyze.getAcquisitionResults(acquisition{:});
    resultsTable = vertcat(resultsTable,T);
end
end