function flickerAnnulus(obj,framebuffer,framerate)
%FLICKERANNULUS Summary of this function goes here
%   Detailed explanation goes here

% Set to first frame
obj.annulus.RGB = framebuffer(1,:);
framebuffer = framebuffer(2:end,:);

% Loop
timeNextFlip = mglGetSecs + 1/framerate;
while ~isempty(framebuffer)
    if mglGetSecs > timeNextFlip
        obj.annulus.RGB = framebuffer(1,:);
        framebuffer = framebuffer(2:end,:);
    end
end

end