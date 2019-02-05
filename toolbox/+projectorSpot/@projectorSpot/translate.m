function translate(obj,translation)
% Translate element(s) of the projector spot (spot, annulus)
%
% Syntax:
%
% Description:
%
% Input:
%    obj         - projectorSpot object
%    translation - 2x2 numeric matrix, where the first row defines
%                  horizontal and vertical translation of the central spot,
%                  and the second row defines the translation of the
%                  annulus
%
% Output:

obj.center = obj.center + translation;

end