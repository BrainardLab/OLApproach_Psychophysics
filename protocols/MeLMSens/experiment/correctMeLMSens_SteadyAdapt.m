function corrections = correctMeLMSens_SteadyAdapt(directions, oneLight, calibration, radiometer, varargin)
% Correct nominal directions for MeLMSens_SteadyAdapt protocol
%
% Syntax:
%   CorrectMeLMSens_SteadyAdapt(directions, oneLight, radiometer)
%   CorrectMeLMSens_SteadyAdapt(directions, oneLight, radiometer,...)
%   corrections = CorrectMeLMSens_SteadyAdapt(directions, ...)
%
% Description:
%    Helper function that corrects the given directions and backgrounds for
%    use in a session of the MeLMSens_SteadyAdapt protocol.
%
% Inputs:
%    directions  - containers.Map containing the directions, as returned by
%                  MakeNominalMeLMSens_SteadyAdapt
%    oneLight    - OneLight-object device driver
%    calibration - scalar struct, containing calibration information for
%                  oneLight
%    radiometer  - Radiometer-object device driver for spectroradiometer.
%
% Outputs:
%    directions  - input containers.Map, each direction in which has been
%                  corrected.
%                   
% Optional keyword arguments:
%    any kwarg that OLCorrectDirection takes
%
% See also:
%    RunMeLMSens_SteadyAdapt, MakeNominalMeLMSens_SteadyAdapt,
%    OLCorrectDirection

% History:
%    09/03/18  jv   wrote CorrectMeLMSens_SteadyAdapt, based on
%                   MakeNominalMeLMSens_SteadyAdapt

%% Define correction params
parser = inputParser;
parser.addRequired('directions');
parser.addRequired('oneLight');
parser.addRequired('radiometer');
parser.addParameter('smoothness',.001);
parser.KeepUnmatched = true;
parser.parse(directions, oneLight, radiometer, varargin{:});

correctionArgs = parser.Unmatched;
correctionArgs.smoothness = parser.Results.smoothness;

backgroundNames = ["LMS_low","LMS_high","Mel_low","Mel_high"];

%% Initialize
input('<strong>Place eyepiece in radiometer, and press any key to start correcting directions.</strong>\n'); pause(5);
fprintf("<strong>Correcting backgrounds and directions...</strong>\n");
corrections = containers.Map();

%% Get lightlevelScalar
fprintf("Measuring lightlevel scale factor,...");
lightlevelScalar = OLMeasureLightlevelScalar(oneLight,calibration,radiometer);
fprintf("%.3f.\n",lightlevelScalar);

%% Correct backgrounds
for bb = backgroundNames
    fprintf("Correcting background %s...",bb);
    OLCorrectDirection(directions(char(bb)),directions('null'), oneLight, radiometer,...
                    'receptors',[],... % don't pass receptors to background correction; want to get correct to SPD
                    'lightlevelScalar',lightlevelScalar,...
                    correctionArgs);
    corrections(char(bb)) = directions(char(bb)).describe.correction;            
    fprintf('done.\n');
end
                
%% Correct flicker directions
for bb = backgroundNames
    dd = sprintf('FlickerDirection_%s',bb);
    fprintf("Correcting direction %s...",dd);
    OLCorrectDirection(directions(dd), directions(char(bb)),...
                        oneLight, radiometer,...
                        'lightlevelScalar',lightlevelScalar,...
                        correctionArgs);
    corrections(dd) = directions(dd).describe.correction;
    fprintf("done.\n");
end

%%
fprintf("<strong>Corrections succesfully completed.</strong>\n\n");
end