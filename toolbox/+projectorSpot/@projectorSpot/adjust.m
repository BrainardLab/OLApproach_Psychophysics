function adjust(obj,inputHandler)
%ADJUST Summary of this function goes here
%   Detailed explanation goes here

targetName = 'spot';

while true %% Main loop
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
            translation = [0 0];
        case "left"
            translation = [-1 0];
        case "right"
            translation = [+1 0];
        case "up"
            translation = [0 +1];
        case "down"
            translation = [0 -1];
        case "toggle"
            translation = [0 0];
            obj.toggle();
    end
    
    switch targetName
        case 'spot'
            obj.spotCenter = obj.spotCenter + translation;
        case 'annulus'
            obj.annulusCenter = obj.annulusCenter + translation;
    end
end

end