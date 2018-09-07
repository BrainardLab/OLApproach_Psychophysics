function validations = validateMeLMSens_SteadyAdapt(directions, oneLight, radiometer, varargin)
% Correct nominal directions for MeLMSens_SteadyAdapt protocol
%
% Syntax:
%   validateMeLMSens_SteadyAdapt(directions, oneLight, radiometer)
%   validateMeLMSens_SteadyAdapt(directions, oneLight, radiometer,...)
%   directions = validateMeLMSens_SteadyAdapt(directions, ...)
%
% Description:
%    Helper function that, for a given calibration, returns the directions
%    and backgrounds for use in a session of the MeLMSens_SteadyAdapt
%    protocol.
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
%    validations - containers.Map containing the validation structs for
%                  each direction
%                   
% Optional keyword arguments:
%    any kwarg that OLValidateDirection takes
%
% See also:
%    RunMeLMSens_SteadyAdapt, MakeNominalMeLMSens_SteadyAdapt,
%    OLValidateDirection, CorrectNominalMeLMSens_SteadyAdapt

% History:
%    09/03/18  jv   extracted validateMeLMSens_SteadyAdapt from
%                   RunMeLMSens_SteadyAdapt

%% Parse input
parser = inputParser;
parser.addRequired('directions');
parser.addRequired('oneLight');
parser.addRequired('radiometer');
parser.addParameter('nValidations',1);
parser.KeepUnmatched = true;

parser.parse(directions, oneLight, radiometer, varargin{:});
validationParams = parser.Unmatched;

%% Initialize
input('<strong>Place eyepiece in radiometer, and press any key to start validating directions.</strong>\n'); pause(5);
validations = containers.Map();
fprintf("<strong>Validating backgrounds and directions...</strong>\n");

%% Validate backgrounds
backgroundNames = ["LMS_low","LMS_high","Mel_low","Mel_high"];
for bb = backgroundNames
    fprintf("Validating background %s...",bb);
    for i = 1:parser.Results.nValidations
        validation(i) = OLValidateDirection(directions(char(bb)), directions('null'), oneLight, radiometer, validationParams);
    end
    validations(char(bb)) = validation;
    clear validation;
    fprintf("done.\n");
end

%% Validate flicker directions
for bb = backgroundNames
    fprintf("Validating direction %s...",sprintf('FlickerDirection_%s',bb));
    for i = 1:parser.Results.nValidations
        validation(i) = OLValidateDirection(directions(sprintf('FlickerDirection_%s',bb)), directions(char(bb)), oneLight, radiometer, validationParams);
    end
    validations(sprintf('FlickerDirection_%s',bb)) = validation;
    fprintf("done.\n");
end

%%
fprintf("<strong>Validations succesfully completed.</strong>\n\n");
end