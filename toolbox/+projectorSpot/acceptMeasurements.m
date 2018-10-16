function accept = acceptMeasurements(measurements)
% Display measurements, ask user to accept or reject

%% Define wavelength sampling
S = [380 2 201];

%% Add luminance as column to table
% Calculate CIE1931 luminance
measurements = addvarLum(measurements,S);

%% Compute delta projectorOn-projectorOff
% Subtract projector on - off, to get projector SPD, per location per
% condition
[G, TID] = findgroups(measurements(:,{'location','mirrorsOn'}));
deltaSPD = splitapply(@(x) diff(flipud(x)),measurements.SPD,G);
deltaLum = splitapply(@(x) diff(flipud(x)),measurements.luminance,G);
deltaMeasurements = [TID, table(deltaSPD, deltaLum)];

%% Display
disp(measurements);
disp(deltaMeasurements);

%% Ask user to accept/reject
accept = [];
while isempty(accept)
    resp = GetWithDefault('Accept these measurements? (Y/N)','Y');
    switch upper(resp)
        case "Y"
            accept = true;
        case "N"
            accept = false;
        otherwise
            accept = [];
    end
end

end