function k = getCurrentParamsIndex(obj, whichInterval)

if whichInterval == 1
    k = obj.interval1_paramsCurrIndex;
elseif whichInterval == 2
    k = obj.interval2_paramsCurrIndex;
end