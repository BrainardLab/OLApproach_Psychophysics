function threshold = thresholdFromPsychometricFunction(psychometricFunction,params,criterion)
% THRESHOLDFROMPSYCHOMETRICFUNCTION Get threshold from given parameterized psychometric function
%
%   threshold = THRESHOLDFROMPSYCHOMETRICFUNCTION(func_handle,
%   parameterStruct, criterion)

% Inverse of function at criterion
threshold = psychometricFunction(params,criterion,'inverse');
end