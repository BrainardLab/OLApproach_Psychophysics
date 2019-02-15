%% Get calibration
calibration = OLGetCalibrationStructure;
observerAge = 32;

%% Define target parameter space
% Unipolar mel contrast
contrast_target_range_mel = (50:50:750)/100;     % [50% : 750%]

% Bipolar LMS contrast
contrast_target_range_LMS = (.5:.5:20)/100;         % [ .5% :  20%]

% Tolerance to enforce L = M = S
tolerance = 1e-3; % 1e-2 = 1% contrast; so 1e-3 = .1% contrast

%% Create directions
table_contrasts_meldirections = table();
table_contrasts_LMSdirections = table();

for contrast_target_mel = contrast_target_range_mel
    fprintf('Mel target contrast: %.0f%%...', contrast_target_mel*100);
    
    % Get directions
    [Mel_low, Mel_step, Mel_high] = MelUnipolarAtTargetContrast(contrast_target_mel,calibration,observerAge);
    receptors = Mel_step.describe.directionParams.T_receptors;
    
    % Get nominal receptor contrasts
    contrasts_nominal_receptors = Mel_step.ToDesiredReceptorContrast(Mel_low,receptors);
    
    % Nominal melanopsin contrast
    contrast_nominal_mel = contrasts_nominal_receptors(4);
    
    % Nominal splatter (L, M, S cone) contrasts)
    contrasts_nominal_mel_splatter = contrasts_nominal_receptors(1:3);
   
    % Print
    fprintf('nominal: %.0f%%\n', contrast_nominal_mel*100);
    
    % Store in table
    entry = table(contrast_target_mel, ...
                  contrast_nominal_mel, ...
                  contrasts_nominal_mel_splatter',...
                  'VariableNames',{'target','nominal','splatter'});
    table_contrasts_meldirections = [table_contrasts_meldirections; entry];
    
    for contrast_target_LMS = contrast_target_range_LMS
        fprintf('\tLMS contrast: %.1f%%...', contrast_target_LMS*100);

        % Get directions
        LMS_low = LMSBipolarOnBackground(contrast_target_LMS, Mel_low, observerAge);
        LMS_high = LMSBipolarOnBackground(contrast_target_LMS, Mel_high, observerAge);
               
        % Get nominal receptor contrasts
        contrasts_nominal_LMS_low = LMS_low.ToDesiredReceptorContrast(Mel_low,receptors);
        contrasts_nominal_LMS_high = LMS_high.ToDesiredReceptorContrast(Mel_high,receptors);
        
        % Nominal LMS (mean) contrast, separate for pos/neg components
        contrast_nominal_LMS_low_pos = mean(contrasts_nominal_LMS_low(1:3,1));
        contrast_nominal_LMS_low_neg = mean(contrasts_nominal_LMS_low(1:3,2));        
        contrast_nominal_LMS_high_pos = mean(contrasts_nominal_LMS_high(1:3,1));
        contrast_nominal_LMS_high_neg = mean(contrasts_nominal_LMS_high(1:3,2));

        % Determine total error from L = M = S, separate for pos/neg
        % components
        inequality_low_pos = max(abs(contrasts_nominal_LMS_low(1:3,1)-contrast_nominal_LMS_low_pos));
        inequality_low_neg = max(abs(contrasts_nominal_LMS_low(1:3,2)-contrast_nominal_LMS_low_neg));
        inequality_high_pos = max(abs(contrasts_nominal_LMS_high(1:3,1)-contrast_nominal_LMS_high_pos));
        inequality_high_neg = max(abs(contrasts_nominal_LMS_high(1:3,2)-contrast_nominal_LMS_high_neg));
        
        % Sum error from L = M = S over pos/neg
        inequality_low = inequality_low_pos + inequality_low_neg;
        inequality_high = inequality_high_pos + inequality_high_neg;
        
        % Determine pos/neg assymmetry
        assymmetry_low = contrast_nominal_LMS_low_pos + contrast_nominal_LMS_low_neg;
        assymmetry_high = contrast_nominal_LMS_high_pos + contrast_nominal_LMS_high_neg;
        
        % Skip if inequality > tolerance
        if inequality_low > tolerance
            fprintf('skipped; inequality_low: %f\n',inequality_low);            
            continue;
        end
        if inequality_high > tolerance
            fprintf('skipped; inequality_high: %f\n',inequality_high);            
            continue;
        end

        % Skip if assymmetry > tolerance
        if assymmetry_low > tolerance
            fprintf('skipped; assymmetry_low: %f\n',assymmetry_low);
            continue;
        end
        if assymmetry_high > tolerance
            fprintf('skipped; assymmetry_high: %f\n',assymmetry_high);            
            continue;
        end
        
        % Nominal splatter, averaged over pos/neg components
        contrasts_splatter_LMS_low = mean(abs(contrasts_nominal_LMS_low),2);
        contrasts_splatter_LMS_high = mean(abs(contrasts_nominal_LMS_low),2);        
        
        % Nominal LMS contrast, combined
        contrast_nominal_LMS_low = mean([contrast_nominal_LMS_low_pos,...
                                        abs(contrast_nominal_LMS_low_neg)]);
        contrast_nominal_LMS_high = mean([contrast_nominal_LMS_high_pos,...
                                        abs(contrast_nominal_LMS_high_neg)]);        

        % Store in table
        entry = table(contrast_target_mel,...
                      contrast_nominal_mel,...
                      contrast_target_LMS,...
                      contrast_nominal_LMS_low,...
                      contrast_nominal_LMS_high,...
                      contrasts_splatter_LMS_low',...
                      contrasts_splatter_LMS_high',...
                      'VariableNames',{'Mel_target','Mel_nominal','LMS_target',...
                                       'LMS_low','LMS_high',...
                                       'splatter_low','splatter_high'});
        table_contrasts_LMSdirections = [table_contrasts_LMSdirections; entry];                           
        
        fprintf('done.\n');
    end 
end

%% Plot params
contrast_as_percent = true;

%% Plot target vs. nominal Mel contrast
figure();
ax = axes();
plot(ax,...
    table_contrasts_meldirections.target*(1+contrast_as_percent*99),...
    table_contrasts_meldirections.nominal*(1+contrast_as_percent*99),...
    '-o');

xlabel(ax,'Target Melanopsin contrast (%)');
xlim([0, max([xlim ylim])]);

ylabel(ax,'Nominal Melanopsin contrast (%)');
ylim([0, max([xlim ylim])]);

title(ax,'Achievable nominal melanopsin unipolar contrast');
axis('square');
line(xlim, ylim,'LineStyle',':','Color','k')

%% Plot nominal Mel contrast vs. splatter
figure();
ax = axes();
h = plot(ax,...
         table_contrasts_meldirections.nominal*(1+contrast_as_percent*99),...
         table_contrasts_meldirections.splatter*(1+contrast_as_percent*99),...
         '-o');
h(1).Color = 'r';
h(2).Color = 'g';
h(3).Color = 'b';

xlabel(ax,'Nominal Melanopsin contrast (%)');
xlim([0, max(xlim)]);

ylabel(ax,'Nominal splatter contrast (%)');
ylim([0, max(ylim)]);

title(ax,'Cone splatter as a function of nominal melanopsin unipolar contrast');
legend({'L','M','S'});

%% LMS contrast vs. mel contrast
figure();
ax = axes();
l = plot(table_contrasts_LMSdirections.Mel_nominal*100,...
     [table_contrasts_LMSdirections.LMS_low, table_contrasts_LMSdirections.LMS_high]*100,...
     ' .','MarkerSize',10);
l(1).Marker = '.';
l(2).Marker = 'o';

xlabel(ax,'Nominal Melanopsin contrast (%)');
xlim([0, max(xlim)]);

ylabel(ax,'Nominal LMS bipolar contrast (%)');
ylim([0, max(ylim)+2]);

title(ax,'LMS bipolar contrast as a function of melanopsin contrast');
legend({'Low background','High background'});

%% LMS bipolar splatter
% Transform splatter into matrix, where each row is a LMS_target, and each
% column is a Mel_target, and L, M and S are panes
splatter_matrix_low = zeros(numel(contrast_target_range_LMS),...
                        numel(contrast_target_range_mel),...
                        3);
splatter_matrix_high = zeros(numel(contrast_target_range_LMS),...
                        numel(contrast_target_range_mel),...
                        3);                    
for i = 1:height(table_contrasts_LMSdirections)
   e = table_contrasts_LMSdirections(i,:);
   rowIdx = find(e.LMS_target == contrast_target_range_LMS);
   colIdx = find(e.Mel_target == contrast_target_range_mel);
   
   splatter_matrix_low(rowIdx,colIdx,1) = e.splatter_low(1)*e.LMS_low;
   splatter_matrix_low(rowIdx,colIdx,2) = e.splatter_low(2)*e.LMS_low;
   splatter_matrix_low(rowIdx,colIdx,3) = e.splatter_low(3)*e.LMS_low;

   splatter_matrix_high(rowIdx,colIdx,1) = e.splatter_high(1)*e.LMS_high;
   splatter_matrix_high(rowIdx,colIdx,2) = e.splatter_high(2)*e.LMS_high;
   splatter_matrix_high(rowIdx,colIdx,3) = e.splatter_high(3)*e.LMS_high;
end
splatter_matrix_low = splatter_matrix_low/(max(max(max(splatter_matrix_low))));
splatter_matrix_high = splatter_matrix_high/(max(max(max(splatter_matrix_high))));

figure();
ax = axes();
imagesc(ax,splatter_matrix_low);
xlabel(ax,'Target Melanopsin contrast (%)');
xticks(1:numel(contrast_target_range_mel));
xticklabels(contrast_target_range_mel*100);
ax.YDir = 'normal';
yticks(1:numel(contrast_target_range_LMS));
yticklabels(contrast_target_range_LMS*100);
ylabel(ax,'Target LMS contrast (%)');