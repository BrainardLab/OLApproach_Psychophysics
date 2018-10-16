function plotLumsRawLocation(lums, varargin)
parser = inputParser;
parser.addRequired('lums',@isnumeric);
parser.addParameter('ax',[]);
parser.addParameter('legend',true);
parser.parse(lums, varargin{:});

if isempty(parser.Results.ax)
    axes();
else
    axes(parser.Results.ax);
end
hold on;

axes(parser.Results.ax); hold on;
bar(lums);
xticks([1 2]);
xticklabels({'on', 'off'});

if parser.Results.legend
    legend('mirrors on','mirrors off');
end

end