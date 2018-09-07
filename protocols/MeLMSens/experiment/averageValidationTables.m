function resultsLuminancesBg = averageValidationTables(luminancesBg, contrastsBg, contrastsFlicker)
%% Average background luminances
[G,direction] = findgroups(luminancesBg.direction);
[median, ~,~,~,CI] = splitapply(@multiStats,luminancesBg.lumActual,G);
desired = splitapply(@unique,luminancesBg.lumDesired,G);
resultsLuminancesBg = table(direction,desired,median,CI);
resultsLuminancesBg = [resultsLuminancesBg rowfun(@(x,y) x >= y(1) && x <= y(2),resultsLuminancesBg,...
                    'InputVariables',{'desired','CI'},...
                    'OutputVariableNames','inCI')];

%% Average background contrasts


%% Average flicker contrasts

end

function [med, stdSample, semean, semedian, CImedian] = multiStats(x)
    med = median(x);
    stdSample = std(x);
    semean = stdSample/sqrt(length(x));
    semedian = 1.2533 * semean;
    CImedian = ([-1.96, +1.96] * semedian) + med;
end