function adjust(obj,action)
%ADJUST Summary of this function goes here
%   Detailed explanation goes here

targetName = 'spot';

switch action
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
        translation = [translation; 0 0];
    case 'annulus'
        translation = [0 0; translation];
end

obj.translate(translation);

end