function label = getParamLabel(obj, whichInterval)

if whichInterval == 1
    label = obj.interval1_paramsLabel;
elseif whichInterval == 2
    label = obj.interval2_paramsLabel;
end

