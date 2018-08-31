function toggleProjectorSpot(projectorWindow,varargin)
% Toggles a projector spot on or off
%
% Syntax:
%   toggleProjectorSpot(projectorWindow,true);
%   toggleProjectorSpot(projectorWindow,off);
%   toggleProjectorSpot(projectorWindow);
%
% Description:
%    Detailed explanation goes here
%
% Inputs:
%    projectorWindow - GLWindow, opened, with objects defining a
%                      projector spot.
%    toggleOn        - boolean, toggle projector spot on? If true, enable
%                      all objects; if false, disable all objects; if 
%                      empty, toggle to off if on, or vice versa
%
% Outputs:
%    None.           - Objects defining projector spot have now been
%                      enabled or disabled appropriately.
%
% Optional key/value arguments:
%    None.
%
% See also:
%    GLWindow, makeProjectorSpot, addProjectorSpot

% History:
%    07/17/18  jv  wrote it.

%% Input parser
parser = inputParser;
parser.addRequired('projectorWindow',@(x) isa(x,'GLWindow'));
parser.addOptional('toggleOn',[],@islogical);
parser.parse(projectorWindow, varargin{:});

%% Toggle
try
    %% Open window (might not be necessary, but let's do it anyway)
    projectorWindow.open;

    %% Figure out if toggling on or off
    if isempty(parser.Results.toggleOn) % not specified by caller
        objectNameList = projectorWindow.showQueue(true);
        if ~isempty(objectNameList)
            isOn = projectorWindow.getObjectProperty(objectNameList{1},'Enabled');
        else
            isOn = false;
        end
        toggleToOn = ~isOn;
    else
        toggleToOn = parser.Results.toggleOn; % specified by caller
    end

    %% Toggle on/off
    if toggleToOn
        projectorWindow.enableAllObjects;
    else
        projectorWindow.disableAllObjects;
    end
    projectorWindow.draw;
catch E
    projectorWindow.close;
    rethrow(E);
end