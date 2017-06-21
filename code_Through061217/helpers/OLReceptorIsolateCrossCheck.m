theDirection = 'LMDirected';
theAge = 26;

% Get spectrum
load(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-' theDirection '.mat'])
backgroundSpd = BoxBLongCableBEyePiece2{end}.data(theAge).backgroundSpd;
modulationSpdSignedPositive = BoxBLongCableBEyePiece2{end}.data(theAge).modulationSpdSignedPositive;
modulationSpdSignedNegative = BoxBLongCableBEyePiece2{end}.data(theAge).modulationSpdSignedNegative;

S = BoxBLongCableBEyePiece2{end}.cal.describe.S;

% Get val spec
%backgroundSpd = cals{end}.modulationBGMeas.meas.pr650.spectrum;
%modulationSpdSignedPositive = cals{end}.modulationMaxMeas.meas.pr650.spectrum;
%modulationSpdSignedNegative = cals{end}.modulationMinMeas.meas.pr650.spectrum;


% Get cones
load T_cones_ss10
T_cones_ss10 = SplineCmf(S_cones_ss10, T_cones_ss10, S);

(T_cones_ss10*(modulationSpdSignedNegative-backgroundSpd))./(T_cones_ss10*backgroundSpd)

% Get CIE 1931
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
photopicLuminanceCdM2 = T_xyz(2,:)*modulationSpdSignedNegative;
chromaticityXY = T_xyz(1:2,:)*modulationSpdSignedNegative/sum(T_xyz*modulationSpdSignedNegative);

%% Analyze the modulation
load(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/modulations/Modulation-' theDirection '-12sWindowedFrequencyModulation-' num2str(theAge) '-full.mat'])
nPrimaries = length(allPrimaries);
allPrimaries = bsxfun(@minus, modulationObj.modulation(2).primaries, modulationObj.modulation(2).backgroundPrimary');
theReferenceMaxPrimary = BoxBLongCableBEyePiece2{end}.data(theAge).modulationPrimarySignedPositive-BoxBLongCableBEyePiece2{end}.data(theAge).backgroundPrimary;

for i = 1:nPrimaries
   theWeight(i) =  theReferenceMaxPrimary \ allPrimaries(i, :)';
end