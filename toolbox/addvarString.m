function T = addvarString(T,s, varargin)
%ADDVARSTRING Add a variable to table, with given string for all rows

%% Validate input
parser = inputParser;
parser.addRequired('T',@istable);
parser.addRequired('s',@(x) isstring(x) || ischar(x));
parser.addParameter('VariableName','string',@ischar);
parser.parse(T,s,varargin{:});

%% Add column
s = repmat(string(s),[height(T),1]);
T = [T, table(s,'VariableNames',{parser.Results.VariableName})];
end