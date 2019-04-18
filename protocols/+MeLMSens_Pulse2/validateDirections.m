function validations = validateDirections(directions, oneLight, radiometer, varargin)
% Correct nominal directions for this protocol
%
% Syntax:
%   validateDirections(directions, oneLight, radiometer)
%   validateDirections(directions, oneLight, radiometer,...)
%   directions = validateDirections(directions, ...)
%
% Description:
%    Helper function that, for a given calibration, returns the directions
%    and backgrounds for use in a session of this protocol.
%
% Inputs:
%    directions  - containers.Map containing the directions, as returned by
%                  makeNominalDirections
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
%    makeNominalDirections, OLValidateDirection, correctDirections

% History:
%    09/03/18  jv   extracted validateMeLMSens_SteadyAdapt from
%                   RunMeLMSens_SteadyAdapt
%    12/23/18  jv   adapted for MeLMSens_Pulse
%    18/04/19  jv   adapted for MeLMSens_Pulse2

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
oneLight.setAll(true);
input('<strong>Place eyepiece in radiometer, and press any key to start validating directions.</strong>\n'); pause(5);
validations = containers.Map();
fprintf("<strong>Validating backgrounds and directions...</strong>\n");
tic;

%% Validate backgrounds
backgroundNames = ["Mel_low","Mel_high"];
for bb = backgroundNames
    fprintf("Validating background %s...",bb);
    for i = 1:parser.Results.nValidations
        validation(i) = OLValidateDirection(directions(char(bb)), directions('null'), oneLight, radiometer, validationParams);
    end
    validations(char(bb)) = validation;
    clear validation;
    fprintf("done.\n");
end

%%
fprintf("<strong>Validations succesfully completed.</strong>\n\n");
toc;
end