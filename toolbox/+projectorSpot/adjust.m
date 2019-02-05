function adjust(pSpot,gamePad)
%ADJUST Summary of this function goes here
%   Detailed explanation goes here
keyBindings = containers.Map();

% Keyboard keybindings
keyBindings('ESACPE') = "escape";
keyBindings('TAB') = "switch";
keyBindings('LEFTARROW') = "left";
keyBindings('RIGHTARROW') = "right";
keyBindings('UPARROW') = "up";
keyBindings('DOWNARROW') = "down";
keyBindings('SPACE') = "toggle";

% GamePad keybindings
keyBindings('GP:LOWERLEFTTRIGGER') = "switch";
keyBindings('GP:UPPERLEFTTRIGGER') = "switch";
keyBindings('GP:LOWERRIGHTTRIGGER') = "switch";
keyBindings('GP:UPPERRIGHTTRIGGER') = "switch";
keyBindings('GP:A') = "escape";
keyBindings('GP:B') = "escape";
keyBindings('GP:NORTH') = "up";
keyBindings('GP:SOUTH') = "down";
keyBindings('GP:WEST') = "left";
keyBindings('GP:EAST') = "right";
keyBindings('GP:Y') = "toggle";

% Make inputHandler
inputHandler = responseSystem(keyBindings, gamePad);

% Adjust
pSpot.show();
targetName = 'spot';
while true
    action = inputHandler.waitForResponse();
    switch action
        case "escape"
            return
        case "switch"
            if strcmp(targetName,'spot')
                targetName = 'annulus';
            else
                targetName = 'spot';
            end          
        otherwise
            pSpot.adjust(action, targetName);
    end
end