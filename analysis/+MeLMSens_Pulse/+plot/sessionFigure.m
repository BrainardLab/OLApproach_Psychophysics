function F = sessionFigure(session)
% Plots staircases and psychometric fits for all acquisition of session
%
% Syntax:
%   plotSessionTrials(session)
%   F = plotSessionTrials(session)
%
% Description:
%	 Plot the staircases and psychometric function fits for session. Left
%	 hand side will plot staircases for the 2 acquisitions per session: 'No
%	 Pedestal' and 'Pedestal'. Right hand panel will plot one large plot
%	 with both psychometric
%    function fits.
%
% Inputs:
%    session - containers.Map() containing acquisitions under the keys
%              'NoPedestal' and 'Pedestal'
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
%    2018.10.31  jv   wrote plotSessionTrials
%    2019.02.26  jv   copied and adapted for MeLMSens_Pulse

F = figure();

% Two acquisitions per session: 'No Pedestal' and 'Pedestal'.
acquisition_pedestal = session('Pedestal');
acquisition_noPedestal = session('NoPedestal');

% Each acquisition gets 2 plots: staircases in one, psychometric function
% fits in the other.
% Thus:
ax_staircases_pedestal    = subplot(2,2,1);
ax_staircases_noPedestal     = subplot(2,2,3);

% Plot staircases
% Ask the acquisitions to plot the staircases in the specified axes. Update
% the titles to indicate the acquisition name.
acquisition_pedestal.plotStaircases('ax',ax_staircases_pedestal); title('Pedestal staircases');
acquisition_noPedestal.plotStaircases('ax',ax_staircases_noPedestal); title('No Pedestal staircases');

% Plot combined psychometric functions
ax_psychometricFunctions = subplot(1,2,2);
MeLMSens_Pulse.plot.sessionPsychometricFunctions(session,'ax',ax_psychometricFunctions);
end