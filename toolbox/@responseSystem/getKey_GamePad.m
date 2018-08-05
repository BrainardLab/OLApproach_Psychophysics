function button = getKey_GamePad(gamePad)
% Summary of this function goes here
%   Detailed explanation goes here

button = gamePad.getKeyEvent();
if ~isempty(button)
    button = button.charCode;
end

end