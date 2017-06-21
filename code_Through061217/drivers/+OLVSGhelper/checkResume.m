function [readyToResume, abort] = checkResume(readyToResume, hintSound)
    % [readyToResume, abort] = OLVSG.checkResume(readyToResume, stopsBackgroundIdle, starts, hintSound)
    % Checks whether suject is okay to resume with next trial.

    % Suppress keypresses going to the Matlab window.
    ListenChar(2); 

    mglWaitSecs(2);
    readyToResume = true;
    abort = false;
%     resume = false;
%     % Flush our keyboard queue.
%     fprintf('Waiting for a key press ...\n');
%     Speak('Waiting for key press', []);
%     mglGetKeyEvent;
%     
%     % Flush our keyboard queue.
%     gamePad = GamePad();
%     
%     while (resume == false)
%         %fprintf('waiting for response.'); This started working after adding
%         %the pause...keep in mind 4 future
%         pause(.1);
%         [action, time] = gamePad.read();
%         % If a key was pressed, get the key and exit.
%         switch (action)
%             case gamePad.buttonChange
%                 sound(hintSound.y, hintSound.fs);
%                 readyToResume = true;
%                 abort = false;
%                 resume = true;
%         end
%     end
end