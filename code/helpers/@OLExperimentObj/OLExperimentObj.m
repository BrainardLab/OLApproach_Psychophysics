function expt = OLExperimentObj(experimentType, varargin)
% expt = OLExperimentObj(experimentType, varargin)
%
% Description: Creates a experiment  object.
%
if (nargin < 2)
    error('Usage: st = OLPsychophysicsObj(experimentType, property-list...)');
end

% Create parser object
parser = inputParser;

% Parser values common to all experiment types.
parser.addRequired('experimentType', @ischar);

% Create the input parser object based on the type of experiment  specified.
% We use the addOptional method because it allows for flexible input formatting,
% but actual passing of these arguments is enforced by checking below.
experimentType = lower(experimentType);
switch experimentType
    case '2ifc'
        parser.addOptional('olRefreshRate', @isscalar);
        % First interval
        parser.addOptional('interval1_olStarts', @isarray);
        parser.addOptional('interval1_olStops', @isarray);
        parser.addOptional('interval1_paramsValues', @isscalar);
        parser.addOptional('interval1_paramsCurrIndex', @isscalar);
        parser.addOptional('interval1_isFlicker', @islogical);
        parser.addOptional('interval1_duration', @isscalar);
        parser.addOptional('interval1_paramsLabel', @isstr);
        
        % Second interval
        parser.addOptional('interval2_olStarts', @isarray);
        parser.addOptional('interval2_olStops', @isarray);
        parser.addOptional('interval2_paramsValues', @isscalar);
        parser.addOptional('interval2_paramsCurrIndex', @isscalar);
        parser.addOptional('interval2_isFlicker', @islogical);
        parser.addOptional('interval2_duration', @isscalar);
        parser.addOptional('interval2_paramsLabel', @isstr);
        
        % Background
        parser.addOptional('bg_olStarts', @isarray);
        parser.addOptional('bg_olStops', @isarray);
        parser.addOptional('isi', @isscalar);
        
    case 'adjustment'
        parser.addOptional('olRefreshRate', @isscalar);
        parser.addOptional('interval1_olStarts', @isarray);
        parser.addOptional('interval1_olStops', @isarray);
        parser.addOptional('interval1_paramsValues', @isscalar);
        parser.addOptional('interval1_paramsCurrIndex', @isscalar);
        parser.addOptional('interval1_isFlicker', @islogical);
        parser.addOptional('interval1_duration', @isscalar);
        parser.addOptional('interval1_paramsLabel', @isstr);
        parser.addOptional('bg_olStarts', @isarray);
        parser.addOptional('bg_olStops', @isarray);
        parser.addOptional('isi', @isscalar);
    otherwise
        error('Invalid experiment  type: %s', experimentType);
end

% Execute the parser to make sure input is good.
parser.parse(experimentType, varargin{:});

% Create a standard Matlab structure from the parser results.
expt = parser.Results;

% Create class
expt = class(expt, 'OLExperimentObj');

