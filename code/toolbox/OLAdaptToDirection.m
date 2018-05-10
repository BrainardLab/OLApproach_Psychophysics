function OLAdaptToDirection(direction, oneLight, duration, varargin)
% Show OLDirection as adaptation stimulus
%
% Syntax:
%   OLAdaptToDirection(direction, OneLight, duration)
%
% Description:
%    Puts the given Direction on the OneLight, for the specified duration.
%    Default gives a verbal countdown feedback every 30 seconds. 
%
%    Note: this routine stays busy executing for the entire duration, i.e.,
%    does not return control to caller until duration has elapsed.
%
% Inputs:
%    direction - OLDirection object 
%    OneLight  - OneLight object controlling a (simulated) OneLight device.
%    duration  - numeric scalar, adaptation duration in seconds.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    'countdownInterval' - numeric scalar, interval (in seconds) between
%                          verbal countdowns. Default 30s. If set to 0,
%                          will not give any verbal feedback.
%
% See also:
%    OLShowDirection

% History:
%    05/08/18  jv  wrote it.

%% Input validation
parser = inputParser;
parser.addRequired('direction',@(x) isa(x,'OLDirection'));
parser.addRequired('oneLight',@(x) isa(x,'OneLight'));
parser.addRequired('duration',@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
parser.addParameter('countdownInterval',30,@(x) validateattributes(x,{'numeric'},{'scalar','positive'}));
parser.parse(direction, oneLight, duration, varargin{:});

%% Set up countdown
if parser.Results.countdownInterval
    countdownTimes = parser.Results.countdownInterval:parser.Results.countdownInterval:duration;
    countdownTimes = fliplr(countdownTimes);
else
    countdownTimes = [];
end

%% Show adaptation
OLShowDirection(direction, oneLight);
Speak(sprintf('Adaptation started, for %d seconds',duration),[],230);
startTime = mglGetSecs;
endTime = mglGetSecs + duration;
eta = endTime-mglGetSecs;
while eta > 0
   if ~isempty(countdownTimes) && eta < countdownTimes(1)
       Speak(sprintf('%d seconds of adaptation remaining',countdownTimes(1)),[],230);
       countdownTimes = countdownTimes(2:end);
   end
   eta = endTime-mglGetSecs;
end
Speak('Adaptation complete.',[],230);

end