function ax = sessionPsychometricFunctions(session, varargin)
% Plots psychometric fits for all acquisitions of session in single plot
%
% Syntax:
%   plotSessionPsychometricFunctions(session)
%   F = plotSessionPsychometricFunctions(session)
%
% Description:
%    Plot both psychometric function fits of a session (two acquisitions)
%    into the same plot.
%
% Inputs:
%    session - containers.Map() containing acquisitions under the keys
%              'NoPedestal' and 'Pedestal'
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
%    2018.10.31  jv   wrote plotSessionTrials
%                     extracted plotSessionPsychometricFunctions
%    2019.02.26  jv   copied and adapted for MeLMSens_Pulse

% Parse input
parser = inputParser();
parser.addRequired('session',@(x)isa(x,'containers.Map'));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.parse(session,varargin{:});
ax = parser.Results.ax;

% Two acquisitions per session: 'No Pedestal' and 'Pedestal'.
acquisition_pedestal = session('Pedestal');
acquisition_noPedestal = session('NoPedestal');

% Plot combined psychometric functions
% Ask the acquisitions to plot the psychometric functions into the same
% axes, so that they're all in one plot. Add legend (but only for the fits,
% not also for the threshold-indicating dashed lines.
acquisition_pedestal.plotPsychometricFunction('ax',ax);
acquisition_noPedestal.plotPsychometricFunction('ax',ax);
subset = findobj(ax.Children,'-regexp','DisplayName','.*psychometric function fit');
names = {subset.DisplayName}';
texts = findobj(ax.Children,'Type','text');
thresholdsStrings = {texts.String}';
thresholdsStrings = strrep(names,'psychometric function fit',thresholdsStrings);
thresholdsStrings = strrep(thresholdsStrings,'_',' ');

legend(subset,thresholdsStrings);
end