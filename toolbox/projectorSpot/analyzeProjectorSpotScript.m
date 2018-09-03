plotAll(SPDs);

%% Support functions
function lums = SPDsLocationToLums(SPDs,S)
lums = cellfun(@(x) SPDToLum(x,S),SPDs);
% lums = SPDToLum(cell2mat(SPDs(:)'),S);
% lums = [lums([1,3]); lums([2, 4])];
end

function plotSPDsForLocation(SPDs, ax)
parser = inputParser;
parser.addRequired('SPDs',@iscell);
axes(ax); hold on;
plot(SPDs{1,1} ,'g-');
plot(SPDs{2,1},'r-');
plot(SPDs{1,2},'g:');
plot(SPDs{2,2},'r:');
xlim([1, length(SPDs{1,1})]);
% legend({'projector on, mirrors on', 'projector Off, mirrors On',...
%     'projector on, mirrors off', 'projector off, mirrors off'},...
%     'NumColumns',2);
end

function plotLumsForLocation(lums, ax)
parser = inputParser;
parser.addRequired('SPDs',@iscell);
axes(ax); hold on;
bar(lums);
xticks([1 2]);
xticklabels({'on', 'off'});
%legend('mirrors on','mirrors off');
end

function F = plotAll(measurements, varargin)
    F = figure();
    for i = 1:2
        for j = 1:2
            idxs = j*4+(i-1)*8+[-1 0];
            M = measurements{i,j};
            plotSPDsForLocation(M,subplot(3,6,idxs(1)));
            plotLumsForLocation(SPDsLocationToLums(M,[380 2 201]),subplot(3,6,idxs(2)))
        end
    end
end

%% Average
function deltaProjectorSPDs = calcDeltaProjectorSPDs(SPDs)
    for i = 1:2
        for j = 1:2
            deltaProjectorSPDs{i,j} = [SPDs{i,j}{1,1}-SPDs{i,j}{2,1}, ...
                                       SPDs{i,j}{1,2}-SPDs{i,j}{2,2}];
        end
    end
end

function avgDeltaProjectorSPDs = averagoOverOLOnOff(deltaProjectorSPDs)
    for i = 1:2
        for j = 1:2
            avgDeltaProjectorSPDs{i,j} = mean(deltaProjectorSPDs,2);
        end
    end
end

% - Subtract projector on - off, to get projector SPD, per location per condition
% - Average SPD across OneLight on/off conditions, per location
%   - SEM, CI (95% CI = +- 1.96 SEM)
% - Average SPD across locations
%   - SEM, CI (95% CI = +- 1.96 SEM)

% Luminance, Trolands
% - Take average SPDs
% - Calculate CIE1931 luminance
% - Calculate photopic trolands
% - Calculate CIE1951 scotopic luminance
% - Calculate scotopic trolands