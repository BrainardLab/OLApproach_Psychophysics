function b = barGroupStack(x)
%BARGROUPSTACK Plot groups of stacked bars
%   Detailed explanation goes here
%
%   In the case where size(x) = (N,M,K), produce M groups of K stacked bars
% 
%   In the case where size(x) = (N,M,1), produce the exact same output as
%   bar(x)
%
%   In the case where size(x) = (N,1,K), produce the exact same output as
%   bar(x,'stacked');
b = bar(x);

end