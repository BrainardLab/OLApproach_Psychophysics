function key = getKey_keyboard
% Summary of this function goes here
%   Detailed explanation goes here

% Check keyboard
keycode = zeros(1,256);
[~, ~, incode] = KbCheck;
keycode = keycode + incode;
key = KbName(keycode);
end