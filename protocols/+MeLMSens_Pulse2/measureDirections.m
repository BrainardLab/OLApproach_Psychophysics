function measurements = measureDirections(directions, oneLight, radiometer, varargin)
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
parser.addParameter('nMeasurements',1);
parser.KeepUnmatched = true;

parser.parse(directions, oneLight, radiometer, varargin{:});
validationParams = parser.Unmatched;
nMeasurements = parser.Results.nMeasurements;

%% Initialize
oneLight.setAll(true);
measurements = containers.Map();
fprintf("<strong>Measuring spectra...</strong>\n");
tic;

%% Measure spectra
spectraNames = ["Mel_low","Mel_high"];
for bb = spectraNames
    measurements(char(bb)) = [];
end
for i = 1:nMeasurements
    for bb = spectraNames
        fprintf("Measuring spectrum %s...",bb);
        validation = OLValidateDirection(directions(char(bb)), directions('null'), oneLight, radiometer, validationParams);
        measurement = validationToMeasurement(validation);
        measurements(char(bb)) = [measurements(char(bb)) measurement];    
    end
    clear measurement;
    fprintf("done.\n");
end

%%
fprintf("<strong>Measurements succesfully completed.</strong>\n\n");
toc;
end