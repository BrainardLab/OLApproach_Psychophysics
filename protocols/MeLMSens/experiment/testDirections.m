function testDirections(directions, receptors, oneLight)
% Test whether all directions can be displayed at all required levels
    
%% Test backgrounds
fprintf('Testing backgrounds...\n');
fprintf('\tTesting Mel_low...');
OLShowDirection(directions('Mel_low'), oneLight);
fprintf('done.\n');

fprintf('\tTesting Mel_high...');
OLShowDirection(directions('Mel_high'), oneLight);
fprintf('done.\n');

fprintf('\tTesting LMS_low...');
OLShowDirection(directions('LMS_low'), oneLight);
fprintf('done.\n');

fprintf('\tTesting LMS_high...');
OLShowDirection(directions('LMS_high'), oneLight);
fprintf('done.\n');

%% Test Mel_low flicker directions
fprintf('Testing flicker on Mel_low...\n');
background = directions('Mel_low');
direction = directions('FlickerDirection_Mel_low');
for flickerContrast = 0:.001:.05
    fprintf('\t Testing at %2.1f%% contrast...',flickerContrast*100);
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    
    fprintf('positive...');
    OLShowDirection(background+scaledDirection, oneLight);
    fprintf('negative...');
    OLShowDirection(background-scaledDirection, oneLight);    
    fprintf('done.\n');
end

%% Test Mel_high flicker directions
fprintf('Testing flicker on Mel_high...\n');
background = directions('Mel_high');
direction = directions('FlickerDirection_Mel_high');
for flickerContrast = 0:.001:.05
    fprintf('\t Testing at %2.1f%% contrast...',flickerContrast*100);
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    
    fprintf('positive...');
    OLShowDirection(background+scaledDirection, oneLight);
    fprintf('negative...');
    OLShowDirection(background-scaledDirection, oneLight);    
    fprintf('done.\n');    
end

%% Test LMS_low flicker directions
fprintf('Testing flicker on LMS_low...\n');
background = directions('LMS_low');
direction = directions('FlickerDirection_LMS_low');
for flickerContrast = 0:.001:.05
    fprintf('\t Testing at %2.1f%% contrast...',flickerContrast*100);
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    
    fprintf('positive...');
    OLShowDirection(background+scaledDirection, oneLight);
    fprintf('negative...');
    OLShowDirection(background-scaledDirection, oneLight);    
    fprintf('done.\n');  
end

%% Test LMS_high flicker directions
fprintf('Testing flicker on LMS_high...\n');
background = directions('LMS_high');
direction = directions('FlickerDirection_LMS_high');
for flickerContrast = 0:.001:.05
    fprintf('\t Testing at %2.1f%% contrast...',flickerContrast*100);
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    
    fprintf('positive...');
    OLShowDirection(background+scaledDirection, oneLight);
    fprintf('negative...');
    OLShowDirection(background-scaledDirection, oneLight);    
    fprintf('done.\n');   
end

end