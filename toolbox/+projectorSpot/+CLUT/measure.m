function measurements = measure(windowObject, CLUT, radiometer)
%% Measurement loop
% Initialize output
measurements = [];

% Loop
for RGB = CLUT'
    fprintf('RGB: [%d %d %d]\n',RGB);
    measurement = projectorSpot.measureRGB(windowObject,RGB',radiometer);
    
    % Append
    measurements = [measurements measurement];
end
fprintf('Done.\n');
end