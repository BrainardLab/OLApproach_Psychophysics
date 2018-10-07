function XData = plotContrastsBipolar(contrastsBipolar)
% Plot bipolar contrasts in barplot
%
% Syntax:
%   plotContrastsBipolar(contrastsBipolar)
%
% Description:
%
% Input:
%    contrastsBipolar - matrix (Nx2) of bipolar contrasts, where first
%                       column defines contrast of the postive component,
%                       and second column defines contrast of the negative
%                       component. Each row defines a bar to be plot (e.g.,
%                       each row/bar is contrast of same spectra on
%                       different receptor, or each row/bar is contrast of
%                       different spectra on same receptor).
%
% Output:
%    None.
%
% Optional keyword arguments:
%    None.
%
% See also:
%    

% History:
%    2018/09/28  jv   wrote plotContrastBipolar

%% Parse input

%% 
b = bar(contrastsBipolar);
XData = [b(1).XData' b(2).XData'];

end