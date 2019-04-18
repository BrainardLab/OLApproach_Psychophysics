function corrections = correctDirections(directions, oneLight, calibration, radiometer, receptors, varargin)
% Correct nominal directions for this protocol
%
% Syntax:
%   correctDirections(directions, oneLight, radiometer)
%   correctDirections(directions, oneLight, radiometer,...)
%   corrections = correctDirections(directions, ...)
%
% Description:
%    Helper function that corrects the given directions and backgrounds for
%    use in a session of the MeLMSens_SteadyAdapt protocol.
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
%    directions  - input containers.Map, each direction in which has been
%                  corrected.
%                   
% Optional keyword arguments:
%    any kwarg that OLCorrectDirection takes
%
% See also:
%    makeNominalDirections, OLCorrectDirection

% History:
%    09/03/18  jv   wrote CorrectMeLMSens_SteadyAdapt, based on
%                   MakeNominalMeLMSens_SteadyAdapt
%    12/23/18  jv   adapted for MeLMSens_Pulse
%    18/04/19  jv   adapted for MeLMSens_Pulse2


%% Define correction params
parser = inputParser;
parser.addRequired('directions');
parser.addRequired('oneLight');
parser.addRequired('radiometer');
parser.addRequired('receptors');
parser.addParameter('smoothness',.001);
parser.KeepUnmatched = true;
parser.parse(directions, oneLight, radiometer, receptors, varargin{:});

correctionArgs = parser.Unmatched;
correctionArgs.smoothness = parser.Results.smoothness;

backgroundPairNames = ["Mel"];
lowBackgroundNames = backgroundPairNames + "_low";
highBackgroundNames = backgroundPairNames + "_high";
backgroundNames = [lowBackgroundNames, highBackgroundNames];

%% Initialize
input('<strong>Place eyepiece in radiometer, and press any key to start correcting directions.</strong>\n'); pause(5);
fprintf("<strong>Correcting backgrounds and directions...</strong>\n");
corrections = containers.Map();
tic;

%% Get lightlevelScalar
fprintf("Measuring lightlevel scale factor,...");
lightlevelScalar = OLMeasureLightlevelScalar(oneLight,calibration,radiometer);
fprintf("%.3f.\n",lightlevelScalar);

%% Correct low backgrounds
for bbL = lowBackgroundNames
fprintf("Correcting background %s to SPD...", bbL);
OLCorrectDirection(directions(char(bbL)),directions('null'),...
                    oneLight, radiometer,...
                    'receptors',[],... % don't pass receptors to background correction; want to correct to SPD
                    'lightlevelScalar',lightlevelScalar,...
                    correctionArgs);
corrections(char(bbL)) = directions(char(bbL)).describe.correction;            
fprintf('done.\n');
end

%% Correct background steps
for bbP = backgroundPairNames
    fprintf("Correcting background pair %s to contrast...",bbP)
    OLCorrectDirection(directions(char(bbP+"Step")),directions(char(bbP+"_low")),...
                        oneLight, radiometer,... 
                        'receptors',receptors,...
                        'lightlevelScalar',lightlevelScalar,...
                        correctionArgs);
    corrections(char(bbP+"Step")) = directions(char(bbP+"Step")).describe.correction;       
    directions(char(bbP+"_high")) = directions(char(bbP+"_low")) + directions(char(bbP+"Step"));
    fprintf('done.\n');
end

%%
fprintf("<strong>Corrections succesfully completed.</strong>\n\n");
toc;
end