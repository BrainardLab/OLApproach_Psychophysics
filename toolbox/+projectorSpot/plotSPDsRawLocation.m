function plotSPDsRawLocation(SPDs, varargin)
parser = inputParser;
parser.addRequired('SPDs',@iscell);
parser.addParameter('ax',[]);
parser.addParameter('legend',true);
parser.parse(SPDs, varargin{:});

if isempty(parser.Results.ax)
    axes();
else
    axes(parser.Results.ax);
end
hold on;

plot(SPDs{1,1} ,'g-');
plot(SPDs{2,1},'r-');
plot(SPDs{1,2},'g:');
plot(SPDs{2,2},'r:');
xlim([1, length(SPDs{1,1})]);
if parser.Results.legend
    legend({'projector on, mirrors on', 'projector Off, mirrors On',...
        'projector on, mirrors off', 'projector off, mirrors off'},...
        'NumColumns',2);
end
end