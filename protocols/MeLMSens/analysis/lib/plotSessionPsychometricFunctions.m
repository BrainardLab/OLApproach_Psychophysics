function ax = plotSessionPsychometricFunctions(session, varargin)
% Plots psychometric fits for all acquisitions of session in single plot
%
% Syntax:
%   plotSessionPsychometricFunctions(session)
%   F = plotSessionPsychometricFunctions(session)
%
% Description:
%    Plot all four psychometric function fits of a session (four
%    acquisitions) into the same plot.
%
% Inputs:
%    session - containers.Map() containing acquisitions under the keys
%              'Mel_low', 'Mel_high', 'LMS_low', 'LMS_high'
%
% Outputs:
%    ax      - Handle to axes containing plot
%
% Optional keyword arguments:
%    'ax'    - Handle to axes to plot in
%
% See also:
%    plotSessionTrials, acquisition.plotPsychometricFunction,
%    acquisition.plotStaircases

% History:
%    2018-10-31  jv   wrote plotSessionTrials
%                     extracted plotSessionPsychometricFunctions

% Parse input
parser = inputParser();
parser.addRequired('session',@(x)isa(x,'containers.Map'));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.parse(session,varargin{:});
ax = parser.Results.ax;

% Four acquisitions per session: Mel high/low, LMS high/low. High and low
% will be plot next to each other on the same row of plots; Mel on the top
% row, LMS on the bottom.
Mel_low = session('Mel_low');
Mel_high = session('Mel_high');
LMS_low = session('LMS_low');
LMS_high = session('LMS_high');

% Plot combined psychometric functions
% Ask the acquisitions to plot the psychometric functions into the same
% axes, so that they're all in one plot. Add legend (but only for the fits,
% not also for the threshold-indicating dashed lines.
Mel_low.plotPsychometricFunction('ax',ax);
Mel_high.plotPsychometricFunction('ax',ax);
LMS_low.plotPsychometricFunction('ax',ax);
LMS_high.plotPsychometricFunction('ax',ax);
subset = findobj(ax.Children,'-regexp','DisplayName','.*psychometric function fit');
names = {subset.DisplayName}';
texts = findobj(ax.Children,'Type','text');
thresholdsStrings = {texts.String}';
thresholdsStrings = strrep(names,'psychometric function fit',thresholdsStrings);
thresholdsStrings = strrep(thresholdsStrings,'_',' ');

legend(subset,thresholdsStrings);
end