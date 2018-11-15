function T = addvarString(T,s, varargin)
%ADDVARSTRING Add variable to table, with given string for all rows
%
%   ADDVARSTRING(T,s) adds a variable (column) 'string1' to table T, where
%   'string' contains string s for all rows. If s is passed in as char
%   array, ADDVARSTRING converts it to string.
%
%   ADDVARSTRING(T,[s1 s2]) adds a variable 'string1' containing s1, and
%   'string2' containing s2 to table T. [s1 s2] must be a string array, or
%   a cellarray of strings (cellstr). 
%
%   ADDVARSTRING(T,s,'VariableNames','name1') adds a variable 'name1'
%   containing string s to table T.
%
%   ADDVARSTRING(T,[s1 s2],'VariableNames',{'name1','name2'}) adds
%   variables 'name1' and 'name2', containing s1 and s2 respectively, to
%   table T.

% (c) Joris Vincent, 2018

%% Validate input
parser = inputParser;
parser.addRequired('T',@istable);
parser.addRequired('s',@(x)validateattributes(x,{'char','string','cell'},{'vector'}));
parser.parse(T,s);
s = string(s);

parser.addParameter('VariableNames',compose("string%d",1:numel(s)'),@(x)validateattributes(x,{'string','cell'},{'vector','numel',numel(s)}));
parser.parse(T,s,varargin{:});

%% Add column
sMat = repmat(string(s),[height(T),1]);
T = [T, array2table(sMat,'VariableNames',cellstr(parser.Results.VariableNames))];
end