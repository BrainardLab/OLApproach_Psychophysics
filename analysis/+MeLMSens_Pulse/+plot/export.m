function export(F, filepath)
%EXPORTCURRENT Summary of this function goes here
%   Detailed explanation goes here

% History:
%    2019.02.26  jv   extracted from sessionFig

% Print to PDF
F.PaperOrientation = 'landscape';
F.PaperPositionMode = 'auto';
print('-fillpage',filepath,'-dpdf');
end