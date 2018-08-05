function GLW_AnnularStimulus()
% GLW_AnnularStimulus()
%
% Annular stimulus which can be moved and resized with button presses. Adopted
% from GLWindow sample code.
%
% Simple but functional.
%
% The program terminates when the user presses the'q' key.
%
% 12/3/13  npc Wrote it.
% 6/23/14  ms  Display an annulus.

% Background
backgroundRGB = [1 1 1]; % Half-on
annulusRGB = [0 0 0]; % Full-on

% The 'inner circle', i.e. the hole
innerCircleDiameter = 78;%100; % px
innerCircleRGB = [0 0 0]%1 1 1]; % Assume that it's the same as background, but it can be changed.

% The 'outer circle'
outerCircleDiameter = 303;%200; % px
outerCircleRGB = annulusRGB;

% Fixation cross
fixationCrossDiameter = 10;
fixationCrossRGB = [0 0 0];

% Define step sizes for the navigation
fineStepSize = 1;
coarseStepSize = 30;

% Get information about the displays attached to our system.
displayInfo = mglDescribeDisplays;

% We will present everything to the last display. Get its ID.
lastDisplay = length(displayInfo);

% Get the screen size
screenSizeInPixels = displayInfo(lastDisplay).screenSizePixel;

win = [];
try
    % Create a full-screen GLWindow object
    win = GLWindow( 'SceneDimensions', screenSizeInPixels, ...
        'BackgroundColor', backgroundRGB,...
        'windowID',        lastDisplay);
    
    % Open the window
    win.open;
    
    % Add stimulus image to the GLWindow
    centerPosition = [0 13];
    win.addOval(centerPosition, [outerCircleDiameter outerCircleDiameter], outerCircleRGB, 'Name', 'outerCircle');
    win.addOval(centerPosition, [innerCircleDiameter innerCircleDiameter], innerCircleRGB, 'Name', 'innerCircle');
    win.addOval(centerPosition, [fixationCrossDiameter fixationCrossDiameter], fixationCrossRGB, 'Name', 'fixationCross');
    
    % Render the scene
    win.draw;
    
    % Wait for a character keypress.
    ListenChar(2);
    FlushEvents;
    
    % Display some information
    disp('Press q to exit');
    disp('Commands:');
    disp(['> aswd for coarse positional adjustment, step size: ' num2str(coarseStepSize) ' px']);
    disp(['> ijkl for fine positional adjustment:' num2str(fineStepSize) ' px']);
    disp(['> 1 (-) and 2 (+) for coarse diameter adjustment [outer circle], step size: ' num2str(coarseStepSize) ' px']);
    disp(['> 3 (-) and 4 (+) for fine diameter adjustment [outer circle], step size: ' num2str(fineStepSize) ' px']);
    disp(['> 5 (-) and 6 (+) for coarse diameter adjustment [inner circle], step size: ' num2str(coarseStepSize) ' px']);
    disp(['> 7 (-) and 8 (+) for fine diameter adjustment [inner circle], step size: ' num2str(fineStepSize) ' px']);
    
    keepLooping = true;
    while (keepLooping)
        
        if CharAvail
            % Get the key
            theKey = GetChar(false, true);
            
            if (theKey == 'q')
                keepLooping = false;
            end
            
            % Navigate: Coarse adjustment
            if (theKey == 's')
                centerPosition(2) = centerPosition(2) - coarseStepSize;
            end
            
            if (theKey == 'w')
                centerPosition(2) = centerPosition(2) + coarseStepSize;
            end
            
            if (theKey == 'a')
                centerPosition(1) = centerPosition(1) - coarseStepSize;
            end
            
            if (theKey == 'd')
                centerPosition(1) = centerPosition(1) + coarseStepSize;
            end
            
            % Navigate: Fine adjustment
            if (theKey == 'k')
                centerPosition(2) = centerPosition(2) - fineStepSize;
            end
            
            if (theKey == 'i')
                centerPosition(2) = centerPosition(2) + fineStepSize;
            end
            
            if (theKey == 'j')
                centerPosition(1) = centerPosition(1) - fineStepSize;
            end
            
            if (theKey == 'l')
                centerPosition(1) = centerPosition(1) + fineStepSize;
            end
            
            % Increase/decrease size of diameters
            if (theKey == '1')
                outerCircleDiameter = outerCircleDiameter-coarseStepSize;
            end
            
            if (theKey == '2')
                outerCircleDiameter = outerCircleDiameter+coarseStepSize;
            end
            
            if (theKey == '3')
                outerCircleDiameter = outerCircleDiameter-fineStepSize;
            end
            
            if (theKey == '4')
                outerCircleDiameter = outerCircleDiameter+fineStepSize;
            end
            
            if (theKey == '5')
                innerCircleDiameter = innerCircleDiameter-coarseStepSize;
            end
            
            if (theKey == '6')
                innerCircleDiameter = innerCircleDiameter+coarseStepSize;
            end
            
            if (theKey == '7')
                innerCircleDiameter = innerCircleDiameter-fineStepSize;
            end
            
            if (theKey == '8')
                innerCircleDiameter = innerCircleDiameter+fineStepSize;
            end
            
            % Make sure that the diameters are not 0
            if innerCircleDiameter == 0
                innerCircleDiameter = 1;
            end
            
            if outerCircleDiameter == 0
                outerCircleDiameter = 1;
            end
                        
            
            % Update the position and dimensions of the circles
            win.setObjectProperty('outerCircle', 'Center', centerPosition);
            win.setObjectProperty('innerCircle', 'Center', centerPosition);
            win.setObjectProperty('fixationCross', 'Center', centerPosition);
            win.setObjectProperty('outerCircle', 'Dimensions', [outerCircleDiameter outerCircleDiameter]);
            win.setObjectProperty('innerCircle', 'Dimensions', [innerCircleDiameter innerCircleDiameter]);
            
            % Print out the position of the annulus
            fprintf('Outer d: %g, Inner d: %g, x: %g, y: %g\n', outerCircleDiameter, innerCircleDiameter, centerPosition(1), centerPosition(2));
            
            % Draw
            win.draw;
        end
    end
    
    % Close the window.
    win.close;
    ListenChar(0);
    
catch e
    disp('An exception was raised');
    
    % Disable character listening.
    ListenChar(0);
    
    % Close the window if it was succesfully created.
    if ~isempty(win)
        win.close;
    end
    
    % Send the error back to the Matlab command window.
    rethrow(e);
    
end  % try

end