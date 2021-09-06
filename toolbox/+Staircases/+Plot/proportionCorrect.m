function S = proportionCorrect(binProportionCorrect, varargin)
%PLOTSTAIRCASEPROPORTIONCORRECT Plot proportion correct resonses of (array of) staircase object(s)
%   plotStaircaseProportionCorrect(staircase) plot proportion correct as a
%   scatterplot. Data are binned, and markers are placed indicating the
%   proportion correct at x = mean value for that bin.
%
%   plotStaircaseProportionCorrect(staircase,'binSize',N) calculates
%   proportion correct over N trials per bin.

%   plotStaircaseProportionCorrect(...,'ax',ax) plot in the specified axes;
%   ax is must be a valid axes-object (i.e., open).
%
%   S = plotStaircaseProportionCorrect(...) returns a handle to the
%   scatter-object containing the scatterplot.
%
%   This function tries to forward unmatched input arguments to scatter(),
%   although no guarantee is made that those will work well.

% History:
%   2018.11.02  J.Vincent wrote plotStaircaseProportionCorrect.
%   2019.03.27  J.Vincent farmed out calculations to other functions
%   2019.04.23  J.Vincent extracted Plot.proportionCorrect

%% Parse input
parser = inputParser;
parser.addRequired('binProportionCorrect');
parser.parse(binProportionCorrect);

parser.addParameter('binN',ones(size(binProportionCorrect)));
parser.addParameter('binCenter',1:1:numel(binProportionCorrect));
parser.addParameter('ax',gca,@(x) isgraphics(x) && strcmp(x.Type,'axes'));
parser.KeepUnmatched = true;
parser.parse(binProportionCorrect, varargin{:});
ax = parser.Results.ax;
parser.addParameter('color',ax.ColorOrder(ax.ColorOrderIndex,:));
parser.parse(binProportionCorrect, varargin{:});
binN = parser.Results.binN;
binCenter = parser.Results.binCenter;

%% Plot
S = scatter(ax,binCenter,binProportionCorrect,...
    (binN+1)*10,... % size is 10 * number of trials in bin
    'filled',...
    'MarkerFaceColor',parser.Results.color,...
    'MarkerEdgeColor',parser.Results.color,...
    'DisplayName','Aggregated proportion correct');
end