function expt = updateParamsIndex(expt, newInt1, newInt2)

if ~isempty(newInt1)
   expt.interval1_paramsCurrIndex = newInt1;
end

if ~isempty(newInt2)
   expt.interval2_paramsCurrIndex = newInt2; 
end