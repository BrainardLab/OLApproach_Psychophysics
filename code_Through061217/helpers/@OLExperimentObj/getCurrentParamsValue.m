function paramsValue = getCurrentParamsValue(obj, whichInterval)

if whichInterval == 1
    k = obj.interval1_paramsCurrIndex;
    paramsValue = obj.interval1_paramsValues(k);
elseif whichInterval == 2
    k = obj.interval2_paramsCurrIndex;
    paramsValue = obj.interval2_paramsValues(k);
end