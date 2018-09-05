function T = bipolarContrastsToTable(contrasts,receptorStrings)
%BIPOLARCONTRASTSTOTABLE Summary of this function goes here
%   Detailed explanation goes here
    b = {}; 
    for a = contrasts' 
        b = [b [a(1), a(2)]]; 
    end
    
    T = cell2table(b,'VariableNames',receptorStrings);
end