function directions = makeNominalDirections(calibration, varargin)
% Make nominal directions for MeLMSens_SteadyAdapt protocol
%
% Syntax:
%   directions = MakeNominalMeLMSens_SteadyAdapt(calibration)
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
%                   'LMS_low':  background with low LMS content
%                   'LMSStep':  unipolar direction generationg 350% LMS 
%                               contrast when added to 'LMS_low'
%                   'LMS_high': background with high LMS content, the sum 
%                               of 'LMS_low' and 'LMSStep'
%                   'FlickerDirection_Mel_low': bipolar LMS on 'Mel_low'
%                   'FlickerDirection_Mel_high': bipolar LMS on 'Mel_high'
%                   'FlickerDirection_LMS_low': bipolar LMS on 'LMS_low'
%                   'FlickerDirection_LMS_high': bipolar LMS on 'LMS_high'\
%                   'null':     the null direction for given calibration
%                   
% Optional key/value pairs:
%    observerAge  - scalar numeric, age of observer for which to create
%                   directions
%
% See also:
%    RunMeLMSens_SteadyAdapt, DemoMeLMSens_SteadyAdapt

% History:
%    07/12/18  jv  extracted from RunMeLMSens_SteadyAdapt

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

%% LMS directed high and low
%  Create a 350% Mel-contrast background+step pair
%  'low' = background, 'high' = background+step.
% LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
% LMSDirectionParams.primaryHeadRoom = 0;
% LMSDirectionParams.modulationContrast = OLUnipolarToBipolarContrast([3.5 3.5 3.5]);
% fprintf('Making LMS low and high directions, [%.2f %.2f %.2f]%% contrast...',OLBipolarToUnipolarContrast(LMSDirectionParams.modulationContrast)*100);
% [directions('LMSStep'), directions('LMS_low')] = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'observerAge', parser.Results.observerAge);
% directions('LMS_high') = directions('LMS_low') + directions('LMSStep');
% fprintf('done.\n');

%% LMS flicker directions
% One 5% flicker direction on each of Mel/LMS high/low
FlickerDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667','alternateDictionaryFunc','OLDirectionParamsDictionary_Psychophysics');
FlickerDirectionParams.primaryHeadRoom = 0;
FlickerDirectionParams.modulationContrast = [.05 .05 .05];
fprintf("Making flicker direction on Mel_low, [%.2f %.2f %.2f]%% contrast...",FlickerDirectionParams.modulationContrast*100);
directions('FlickerDirection_Mel_low') = OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', directions('Mel_low'), 'observerAge', parser.Results.observerAge);
fprintf("done.\n");

fprintf("Making flicker direction on Mel_high, [%.2f %.2f %.2f]%% contrast...",FlickerDirectionParams.modulationContrast*100);
directions('FlickerDirection_Mel_high') = OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', directions('Mel_high'), 'observerAge', parser.Results.observerAge);
fprintf("done.\n");

% fprintf("Making flicker direction on LMS_low, [%.2f %.2f %.2f]%% contrast...",FlickerDirectionParams.modulationContrast*100);
% directions('FlickerDirection_LMS_low') = OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', directions('LMS_low'), 'observerAge', parser.Results.observerAge);
% fprintf("done.\n");
% 
% fprintf("Making flicker direction on LMS_high, [%.2f %.2f %.2f]%% contrast...",FlickerDirectionParams.modulationContrast*100);
% directions('FlickerDirection_LMS_high') = OLDirectionNominalFromParams(FlickerDirectionParams, calibration, 'background', directions('LMS_high'), 'observerAge', parser.Results.observerAge);
% fprintf("done.\n");

%%
fprintf("<strong>Nominal directions succesfully created.</strong>\n\n");
end