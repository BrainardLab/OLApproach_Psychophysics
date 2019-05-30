function adjust(pSpot,gamePad)
%ADJUST Summary of this function goes here
%   Detailed explanation goes here
keyBindings = containers.Map();

% Keyboard keybindings
keyBindings('ESACPE') = "escape";
keyBindings('Q') = "escape";
keyBindings('TAB') = "switch";
keyBindings('LEFTARROW') = "left";
keyBindings('RIGHTARROW') = "right";
keyBindings('UPARROW') = "up";
keyBindings('DOWNARROW') = "down";
keyBindings('Z') = "toggle";

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
targetName = 'macular';
while true
    action = inputHandler.waitForResponse();
    switch action
        case "escape"
            return
        case "switch"
            if strcmp(targetName,'macular')
                targetName = 'annulus';
            else
                targetName = 'macular';
            end          
        otherwise
            pSpot.adjust(action, targetName);
    end
end