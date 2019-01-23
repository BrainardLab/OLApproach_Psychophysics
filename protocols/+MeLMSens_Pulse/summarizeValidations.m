function summarizeValidations(validations)
% Summarize set of validations from MeLMSens_SteadyAdapt protocol
[luminancesBg, contrastsBg, contrastsFlicker] = validationsToTablesMeLMSens_SteadyAdapt(validations);
[avgLuminancesBg, avgContrastsBg, avgContrastsFlicker] = averageValidationTables(luminancesBg,contrastsBg, contrastsFlicker);
disp(avgLuminancesBg);
disp(avgContrastsBg);
disp(avgContrastsFlicker);
end