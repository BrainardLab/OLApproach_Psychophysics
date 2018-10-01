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

a = inner2outer(results);
b = stack(a.med,{'L','M','S','Mel'},'NewDataVariableName','medianContrast','IndexVariableName','receptor');
b.axis = a.axis([1 1 1 1 2 2 2 2]);
c = stack(a.CImedian,{'L','M','S','Mel'},'NewDataVariableName','CImedian','IndexVariableName','receptor');
c.axis = a.axis([1 1 1 1 2 2 2 2]);
results = join(b,c);
results = movevars(results,'axis','Before',1);
results.axis = categorical(results.axis);
results.receptor = categorical(results.receptor);
end


function results = averageContrastsFlicker(contrastsFlicker)
% Identify groups, i.e., direction X receptor
[G,direction, receptor] = findgroups(contrastsFlicker.direction, contrastsFlicker.receptor);

% Get actual contrast median, CI
stats = splitapply(@multiStatsDouble,contrastsFlicker.actual,G);
median = stats.med;
CI = stats.CImedian;

% Get desired contrast
desired = splitapply(@(x) unique(x,'rows'), contrastsFlicker.desired,G);

% Combine into results output
results = table(direction,receptor,desired,median,CI);

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