%% Script to open connections to protocol-independent hardware
%
% Syntax:
%   getHardware();
%
% Description:
%    This script opens connection to hardware that is required by all
%    (current) protocols, and does not require protocol specific
%    configuration. Which devices are opened, and whether they are
%    simulated or not, is defined by the 'simulate' preference in the
%    'OLApproach_Psychophysics' group
%    (getpref('OLApproach_Psychophysics','simulate')).
%
%    This is a script, not a function, to ensure that each hardware
%    connection ends up in the global workspace, and stays there even if
%    there is a problem opening up a later device. This is also means that
%    some devices might be succesfully connected to, while another might
%    fail.
%
%    THIS SCRIPT SHOULD ONLY BE CALLED FROM THE COMMAND LINE / OTHER 
%    SCRIPTS, if called from a function, the device driver objects might
%    enter that function's workspace, and will disconnect upon exiting that
%    function. (This shouldn't happen, because the output variables are
%    declared as global variables. But hey, better safe than sorry).
%
% Inputs:
%    None.
%
% Outputs:
%    The following variables are added to the global workspace.
%    simulate         - struct pulled from the preferences, with boolean
%                       field per device indicating whether that device
%                       should be simulated or not.
%    oneLight         - OneLight object with open connection, as returned
%                       by OneLight('simulate',simulate.oneLight)
%    temperatureProbe - LJTemperatureProbe object
%    radiometer       - Radiometer object, as returned by 
%                       OLOpenSpectroRadiometerObj('PR-670'), OR [] if
%                       simulate.radiometer == true
%    gamePad          - GamePad object, as returned by GamePad()
%
% See also:
%    OneLight, Radiometer, GamePad, getpref

% History:
%    02/25/19  jv   wrote getHardware script

%% Determine which devices to open / simulate
simulate = getpref('OLApproach_Psychophysics','simulate'); % localhook defines what devices to simulate

%% Get OneLight
global oneLight;
global temperatureProbe;
if isfield(simulate,'oneLight')
    % Open up a OneLight device
    oneLight = OneLight('simulate',simulate.oneLight); drawnow;

    if ~simulate.oneLight
        % Get temperatureProbe
        temperatureProbe = LJTemperatureProbe();
        temperatureProbe.open();
    end
end    

%% Get radiometer
global radiometer;
if isfield(simulate,'radiometer')
    % Open up a radiometer
    if ~simulate.radiometer
        oneLight.setAll(true);
        commandwindow;
        input('<strong>Turn on radiometer and connect to USB; press any key to connect to radiometer</strong>\n');
        oneLight.setAll(false);
        pause(3);
        radiometer = OLOpenSpectroRadiometerObj('PR-670');
    else
        radiometer = [];
    end
end

%% Get gamepad
global gamePad;
if isfield(simulate,'gamepad')
    if ~simulate.gamepad
        gamePad = GamePad();
    else
        gamePad = [];
    end
end