function directions = makeNominalOLDirections(calibration, varargin)
% Make nominal directions for MeLMSens_Pulse2 protocol
%
% Syntax:
%   directions = makeNominalOLDirections(calibration)
%
% Description:
%    Helper function that, for a given calibration, returns the directions
%    and backgrounds for use in a session of the MeLMSens_SteadyAdapt
%    protocol.
%
% Inputs:
%    calibration - OneLight calibration struct
%
% Outputs:
%    directions  - containers.Map, with the following directions:
%                   'Mel_low':  background with low melanopic content
%                   'MelStep':  unipolar direction generationg 350% 
%                               melanopsin contrast when added to 'Mel_low'
%                   'Mel_high': background with high melanopic content, the 
%                               sum of 'Mel_low' and 'MelStep'
%                   'null':     the null direction for given calibration
%                   
% Optional key/value pairs:
%    observerAge  - scalar numeric, age of observer for which to create
%                   directions

% History:
%    07/12/18  jv  extracted from RunMeLMSens_SteadyAdapt
%    04/16/19  jv  makeNominalOLDirections for MeLMSens_Pulse2

%% Parse input
parser = inputParser();
parser.addRequired('calibration',@isstruct);
parser.addParameter('observerAge',32,@isnumeric);
parser.parse(calibration, varargin{:});

%% Intialize container
directions = containers.Map();
fprintf("<strong>Making backgrounds and directions...</strong>\n");

%% Null direction
directions('null') = OLDirection_unipolar.Null(calibration);

%% Melanopsin high and low
%  Create a 350% Mel-contrast background+step pair
%  'low' = background, 'high' = background+step.
MelDirectionParams = OLDirectionParamsFromName('MaxMel_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
MelDirectionParams.primaryHeadRoom = 0;
MelDirectionParams.modulationContrast = OLUnipolarToBipolarContrast(3.5);
fprintf('Making Mel low and high directions, %.2f%% contrast...',OLBipolarToUnipolarContrast(MelDirectionParams.modulationContrast)*100);
[directions('MelStep'), directions('Mel_low')] = OLDirectionNominalFromParams(MelDirectionParams, calibration, 'observerAge', parser.Results.observerAge);
directions('Mel_high') = directions('Mel_low') + directions('MelStep');
fprintf('done.\n');

%% 
fprintf("<strong>Nominal directions succesfully created.</strong>\n\n");
end