function receptorContrasts = contrastsFromMeasurements(measurements,receptors)
low = measurements('Mel_low');
high = measurements('Mel_high');

receptorContrasts = [];
for i = 1:numel(low)
    contrasts = measurementsToReceptorContrasts([low(i), high(i)],receptors);
    receptorContrasts = [receptorContrasts contrasts(:,1)];
end
end