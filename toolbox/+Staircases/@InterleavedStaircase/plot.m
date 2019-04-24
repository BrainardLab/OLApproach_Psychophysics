function F = plot(obj,varargin)
%PLOT Summary of this function goes here
%   Detailed explanation goes here

% Parse input
parser = inputParser();
parser.addRequired('obj');
parser.addParameter('threshold',[]);
parser.addParameter('criterion',[]);
parser.parse(obj,varargin{:});
threshold = parser.Results.threshold;
criterion = parser.Results.criterion;


F = figure();

obj.plotTrialSeries('ax',subplot(1,2,1),'threshold',threshold);
obj.plotProportionCorrect('ax',subplot(1,2,2),'threshold',threshold,'criterion',criterion);
end