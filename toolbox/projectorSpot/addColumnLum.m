function T = addColumnLum(T,S)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    T = [T rowfun(@(x) SPDToLum(x',S),T,'InputVariables','SPD',...
        'OutputVariableNames','luminance')];
end