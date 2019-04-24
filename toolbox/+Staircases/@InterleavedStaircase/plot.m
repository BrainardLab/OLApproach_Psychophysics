function F = plot(obj)
%PLOT Summary of this function goes here
%   Detailed explanation goes here

F = figure();

obj.plotTrialSeries('ax',subplot(1,2,1));
obj.plotProportionCorrect('ax',subplot(1,2,2));
end