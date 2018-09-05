function T = unipolarContrastsToTable(contrasts,receptorStrings)
%BIPOLARCONTRASTSTOTABLE Summary of this function goes here
%   Detailed explanation goes here   
    T = array2table(contrasts','VariableNames',receptorStrings);
end