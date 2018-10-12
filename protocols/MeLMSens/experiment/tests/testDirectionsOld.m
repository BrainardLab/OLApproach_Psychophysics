function testDirections(directions, receptors, oneLight)
% Test whether all directions can be displayed at all required levels
    
%% Test backgrounds
OLShowDirection(directions('Mel_low'), oneLight);
OLShowDirection(directions('Mel_high'), oneLight);
OLShowDirection(directions('LMS_low'), oneLight);
OLShowDirection(directions('LMS_high'), oneLight);

%% Test Mel_low flicker directions
background = directions('Mel_low');
direction = directions('FlickerDirection_Mel_low');
for flickerContrast = 0:.001:.05
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    OLShowDirection(background+scaledDirection, oneLight);
    OLShowDirection(background-scaledDirection, oneLight);    
end

%% Test Mel_high flicker directions
background = directions('Mel_high');
direction = directions('FlickerDirection_Mel_high');
for flickerContrast = 0:.001:.05
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    OLShowDirection(background+scaledDirection, oneLight);
    OLShowDirection(background-scaledDirection, oneLight);    
end

%% Test LMS_low flicker directions
background = directions('LMS_low');
direction = directions('FlickerDirection_LMS_low');
for flickerContrast = 0:.001:.05
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    OLShowDirection(background+scaledDirection, oneLight);
    OLShowDirection(background-scaledDirection, oneLight);    
end

%% Test LMS_high flicker directions
background = directions('LMS_high');
direction = directions('FlickerDirection_LMS_high');
for flickerContrast = 0:.001:.05
    scaledDirection = direction.ScaleToReceptorContrast(background, receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
    OLShowDirection(background+scaledDirection, oneLight);
    OLShowDirection(background-scaledDirection, oneLight);    
end

end