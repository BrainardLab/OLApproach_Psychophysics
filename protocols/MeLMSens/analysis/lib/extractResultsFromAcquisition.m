function [contrast, excitationPos, excitationNeg, excitationBackground] = extractResultsFromAcquisition(acquisition)
    validations = acquisition.validationAtThreshold;

    contrastActual = [];
    excitationActual = [];
    for v = validations
        contrastActual = cat(3,contrastActual,v.contrastActual(:,[1,3]));
        excitationActual = cat(3,excitationActual,v.excitationActual(:,1:3));
    end

    % Average over validations
    meanContrastActual = mean(contrastActual,3);
    meanExcitation = mean(excitationActual,3);
    
    % Average over positive and negative excursion
    meanContrastActual = mean(abs(meanContrastActual),2);  
        
    % Return
    contrast = meanContrastActual;
    excitationPos = meanExcitation(:,2);
    excitationNeg = meanExcitation(:,3);  
    excitationBackground = meanExcitation(:,1);
end