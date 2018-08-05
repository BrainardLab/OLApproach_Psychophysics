function key = WaitForKeyChar
% Wait for key press on any device (keyboard, game pad)
% 
% Waits for key press on the game pad.  If no game pad is attached
% to the computer, then it waits for a key presss on the keyboard.
%
% This routine is unfortunately named, since the name doesn't provide
% even a hint that it is aimed at a game pad.

% History:
%    06/18/17  dhb  Provided conditional for keypress.
%    04/30/18  jv   Listen to both gamepad and keyboard

% Initialize the gamepad, if there is one.
try
    gamePad = GamePad();
catch
    gamePad = [];
end

% Wait for a key press, one way or another
KbReleaseWait;
keycodeKeyBoard = zeros(1,256);
while true
    % Check keyboard
    [~, ~, incode] = KbCheck;
    keycodeKeyBoard = keycodeKeyBoard + incode; 
    keyKeyBoard = KbName(keycodeKeyBoard);
    if iscell(keyKeyBoard)
        keyKeyBoard = keyKeyBoard{1};
    end
            
    % Check game pad
    if ~isempty(gamePad)
        keyGamePad = gamePad.getKeyEvent();
        if ~isempty(keyGamePad)
            keyGamePad = keyGamePad.charCode;
        end
    end
    
    % Break if response
    if ~isempty(keyKeyBoard)
        key = keyKeyBoard;
        break;
    end
    if exist('keyGamePad','var') && ~isempty(keyGamePad)
        key = keyGamePad;
        break;
    end
end