function measurements = measure(windowObject, CLUT, radiometer, NRepeats)
%% Measurement loop
% Initialize output
measurements = [];

% Loop
for RGB = CLUT'
    idx = find(unique(RGB == CLUT','rows'));
    fprintf('RGB %d/%d: [%d %d %d]\n',idx,size(CLUT,1),RGB);
    measurement = projectorSpot.measureRGB(windowObject,RGB',radiometer, NRepeats);
    
    % Append
    measurements = [measurements measurement];
end
fprintf('Done.\n');
end