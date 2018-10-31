function F = plotSessionTrials(session)
% Plots staircases and psychometric fits for all acquisition of session
%
% Syntax:
%   plotSessionTrials(session)
%   F = plotSessionTrials(session)
%
% Description:
%       % Four acquisitions per session: Mel high/low, LMS high/low. High and low
% will be plot next to each other on the same row of plots; Mel on the top
% row, LMS on the bottom. Each acquisition gets 2 plots: staircases in one, psychometric function
% fits in the other.
%
% Inputs:
%    session - containers.Map() containing acquisitions under the keys
%              'Mel_low', 'Mel_high', 'LMS_low', 'LMS_high'
%
% Outputs:
%    F       - Handle to figure containing plots
%
% Optional keyword arguments:
%    None.
%
% See also:
%    acquisition.plotPsychometricFunction, acquisition.plotStaircases

% History:
%    2018-10-31  jv   wrote plotSessionTrials
F = figure();

% Four acquisitions per session: Mel high/low, LMS high/low. High and low
% will be plot next to each other on the same row of plots; Mel on the top
% row, LMS on the bottom.
Mel_low = session('Mel_low');
Mel_high = session('Mel_high');
LMS_low = session('LMS_low');
LMS_high = session('LMS_high');

% Each acquisition gets 2 plots: staircases in one, psychometric function
% fits in the other.
% Thus:
Mel_low_staircases      = subplot(2,8,1);
Mel_low_psychometric    = subplot(2,8,2);
Mel_high_staircases     = subplot(2,8,3);
Mel_high_psychometric   = subplot(2,8,4);
LMS_low_staircases      = subplot(2,8,9);
LMS_low_psychometric    = subplot(2,8,10);
LMS_high_staircases     = subplot(2,8,11);
LMS_high_psychometric	= subplot(2,8,12);

% Plot staircases
% Ask the acquisitions to plot the staircases in the specified axes. Update
% the titles to indicate the acquisition name.
Mel_low.plotStaircases('ax',Mel_low_staircases); title('Mel low staircases');
Mel_high.plotStaircases('ax',Mel_high_staircases); title('Mel high staircases');
LMS_low.plotStaircases('ax',LMS_low_staircases); title('LMS low staircases');
LMS_high.plotStaircases('ax',LMS_high_staircases); title('LMS high staircases');

% Plot each psychometric function
% Ask the acquisitions to plot the psychometric functions in the specified 
% axes. Update the titles to indicate the acquisition name.
Mel_low.plotPsychometricFunction('ax',Mel_low_psychometric); title('Mel low psychometric function');
Mel_high.plotPsychometricFunction('ax',Mel_high_psychometric); title('Mel high psychometric function');
LMS_low.plotPsychometricFunction('ax',LMS_low_psychometric); title('LMS low psychometric function');
LMS_high.plotPsychometricFunction('ax',LMS_high_psychometric); title('LMS high psychometric function');

% Plot combined psychometric functions
ax_psychometricFunctions = subplot(1,2,2);
plotSessionPsychometricFunctions(session,'ax',ax_psychometricFunctions);
end