%% Get calibration
calibration = OLGetCalibrationStructure;
observerAge = 32;

%% Define target parameter space
% Unipolar mel contrast
contrast_target_range_mel = (50:50:750)/100;     % [50% : 750%]

% Bipolar LMS contrast
contrast_target_range_LMS = (.5:.5:20)/100;         % [ .5% :  20%]

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
                      'VariableNames',{'Mel_target','Mel_nominal','LMS_target',...
                                       'LMS_low','LMS_high'});
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
         table_contrasts_meldirections.nominal*(1+contrast_as_percent*100),...
         table_contrasts_meldirections.splatter*(1+contrast_as_percent*100),...
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