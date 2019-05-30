function adjust(obj,action, targetName)
%ADJUST Summary of this function goes here
%   Detailed explanation goes here

switch action
    case "left"
        translation = [-1 0 0];
    case "right"
        translation = [+1 0 0];
    case "up"
        translation = [0 +1 0];
    case "down"
        translation = [0 -1 0];
    case "toggle"
        translation = [0 0 0];
        obj.toggle();
    otherwise
        translation = [0 0 0];
end

switch targetName
    case 'annulus'
        obj.annulus.center = obj.annulus.center + translation;
    case 'macular'
        obj.macular.center = obj.macular.center + translation;
        obj.fixation.center = obj.fixation.center + translation;
end

end