%% Open window
wdw = projectorSpot.getWindow('FullScreen',true);

%% Open projector spot
pSpot = projectorSpot.projectorSpot('window',wdw);

%% Open radiometer
radiometer = OLOpenSpectroRadiometerObj('PR-670');

%% Prep for measurement
% Hide macular, hide fixation
pSpot.macular.Visible = false;
pSpot.fixation.Visible = false;

%% Define RGBs to measure
% Background
RGBBackground = [.5 .5 .5];

% Step size: 
% 1 in RGB range [0,255], so 1/255 in range [0,1]
stepSize = 1/255;

% Range
RGBRange = (-10:1:10)';

% RGBs
RGBs = stepSize * RGBRange * [1 1 1] + RGBBackground;

%% Measurement loop
% Initialize output
measurements = [];

% Loop
for RGB = RGBs'
    fprintf('RGB: [%d %d %d]\n',RGB);
    measurement = projectorSpot.measureRGB(pSpot.annulus,RGB',radiometer);
    
    % Append
    measurements = [measurements measurement];
end