function [avgLuminancesBg, avgContrastsBg, avgContrastsFlicker] = averageValidationTables(luminancesBg, contrastsBg, contrastsFlicker)
avgLuminancesBg = averageLuminancesBg(luminancesBg);
avgContrastsBg = averageContrastsBg(contrastsBg);
avgContrastsFlicker = averageContrastsFlicker(contrastsFlicker);
end

function results = averageLuminancesBg(luminancesBg)
%% Average background luminances
[G,direction] = findgroups(luminancesBg.direction);
stats = splitapply(@multiStatsSingle,luminancesBg.lumActual,G);
median = stats.med;
CI = stats.CImedian;
results = table(direction,median,CI);
end

function results = averageContrastsBg(contrastsBg)
% Average actual contrats
results = varfun(@multiStatsSingle,contrastsBg,...
    'GroupingVariables','axis');

% Extract medians, CIs
results.L = removevars(results.multiStatsSingle_L,{'stdSample','semean','semedian'});
results.M = removevars(results.multiStatsSingle_M,{'stdSample','semean','semedian'});
results.S = removevars(results.multiStatsSingle_S,{'stdSample','semean','semedian'});
results.Mel = removevars(results.multiStatsSingle_Mel,{'stdSample','semean','semedian'});
results = removevars(results,{'GroupCount','multiStatsSingle_L','multiStatsSingle_M','multiStatsSingle_S','multiStatsSingle_Mel'});
end


function results = averageContrastsFlicker(contrastsFlicker)
% Average actual contrats
results = varfun(@multiStatsDouble,contrastsFlicker,...
    'GroupingVariables','direction');

% Extract medians, CIs
results.L = removevars(results.multiStatsDouble_L,{'stdSample','semean','semedian'});
results.M = removevars(results.multiStatsDouble_M,{'stdSample','semean','semedian'});
results.S = removevars(results.multiStatsDouble_S,{'stdSample','semean','semedian'});
results.Mel = removevars(results.multiStatsDouble_Mel,{'stdSample','semean','semedian'});
results = removevars(results,{'GroupCount','multiStatsDouble_L','multiStatsDouble_M','multiStatsDouble_S','multiStatsDouble_Mel'});
end

function stats = multiStatsSingle(x)
med = median(x);
stdSample = std(x);
semean = stdSample/sqrt(length(x));
semedian = 1.2533 * semean;
CImedian = ([-1.96, +1.96] .* semedian) + med;
stats = table(med, stdSample, semean, semedian, CImedian);
end

function stats = multiStatsDouble(x)
med = median(x,1);
stdSample = std(x,0,1);
semean = stdSample/sqrt(size(x,1));
semedian = 1.2533 * semean;
CImedian = ([-1.96, +1.96, -1.96, +1.96] .* semedian([1 1 2 2])) + med([1 1 2 2]);
stats = table(med, stdSample, semean, semedian, CImedian);
end