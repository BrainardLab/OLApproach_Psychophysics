function contrast = extractContrastFromAcquisition(acquisition)
    validations = acquisition.validationAtThreshold;

    contrastActual = [];
    for v = validations
        contrastActual = cat(3,contrastActual,v.contrastActual(:,[1,3]));
    end

    % Average over validations
    medianContrastActual = median(contrastActual,3);

    % Average over positive and negative excursion
    medianContrastActual = median(abs(medianContrastActual),2);
    
    % Return
    contrast = medianContrastActual;
end