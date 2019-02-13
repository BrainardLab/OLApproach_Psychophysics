%% Which validations set?
validations = validationsPre;

%% Get receptors
receptors = receptors;

%% Get mel pair validations
validations_mel_high = validations('Mel_high');
validations_mel_low = validations('Mel_low');

%% Get measured SPDs
SPDs_mel_high = [validations_mel_high.SPDcombined];
SPDs_mel_high_measured = [SPDs_mel_high.measuredSPD];

SPDs_mel_low = [validations_mel_low.SPDcombined];
SPDs_mel_low_measured = [SPDs_mel_low.measuredSPD];

%% Calculate contrasts
% This generates a full contrast-matrix between all SPDs, thus also between
% each mel_low SPD and all other mel_low SPDs, and between each mel_high
% SPDs and all other mel_high SPDs.
contrasts = SPDToReceptorContrast([SPDs_mel_low_measured SPDs_mel_high_measured],receptors);

% Ultimately, we are only interested in the contrast between each mel_high
% SPD contrasted with each mel_low SPD. Because of the ordering of SPDs
% (low first, then high), the values indicating the contrast of each
% mel_high SPD on each mel_low SPD is found in the top right corner of this
% matrix -- so the columns middle to end, and the rows top to middle. 
toprows = 1:size(contrasts,2)/2;
rightmostcolumns = size(contrasts,1)/2+1:size(contrasts,1);
contrasts = contrasts(toprows,rightmostcolumns,:);

% Don't care about which mel_high SPD is paired with which specific mel_low
% SPD, so reshape into a [R, H*L] matrix, where R is the number of
% receptors, and H and L are the number of high and low SPDs, respectively.
R = size(contrasts,3);
H = size(contrasts,2);
L = size(contrasts,1);
contrasts = permute(contrasts,[3,1,2]); % reorder dimensions to put R 1st
contrasts = reshape(contrasts,[R, H*L]); % do the reshaping

% Calculate median, SE of median, CI
contrasts_median = median(contrasts,2);
contrasts_SEMedian = 1.253*std(contrasts,0,2)/sqrt(size(contrasts,2));
contrasts_CI = contrasts_median + [-1 1] .* contrasts_SEMedian;

%% Calculate desired contrasts
% Get desired SPDs
SPDs_mel_high = [validations_mel_high.SPDcombined];
SPD_mel_high_desired = unique([SPDs_mel_high.desiredSPD]','rows');

SPDs_mel_low = [validations_mel_low.SPDcombined];
SPD_mel_low_desired = unique([SPDs_mel_low.desiredSPD]','rows');

% Calculate contrasts
contrasts_desired = SPDToReceptorContrast([SPD_mel_low_desired',SPD_mel_high_desired'],receptors);
contrasts_desired = contrasts_desired(:,1);