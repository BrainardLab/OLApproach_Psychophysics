function results = extractResultsFromAcquisition(acquisition)
% Extract table(row) of results from an acquisition
%
% Syntax:
%   results = extractResultsFromAcquisition(acquistion)
%
% Description:
%    From a completed Acquisition_FlickerSensitivity_2IFC, extract the
%    nominal and validated LMS threshold contrast and LMS
%    Just-Noticable-Difference (JND).
%
%    Nominal contrast is the scalar value based on the staircase(s). The
%    validated contrast is the mean measured contrast on the L, M and S
%    cone photoreceptors (averaged over positive and negative excursion of
%    bipolar) for a direction scaled to the nominal contrast value. The
%    nominal JND is the mean predicted excitation difference on the L, M
%    and S cone photoreceptors, based on the nominal background SPD and a
%    direction scaled to the nominal contrast value. The validated JND is
%    the mean measured excitation difference for a direction scaled to the
%    nominal contrast value.
%
% Inputs:
%    acquisition - scalar Acquisition_FlickerSensitivity_2IFC object,
%                  completed.
%
% Outputs:
%    results     - table(), with variables 'axis', 'adaptationLevel',
%                  'quickThresholdContrast', 'fitThresholdContrast',
%                  'validatedThresholdContrast', 'quickJND', 'fitJND',
%                  'validatedJND'
%
% Optional keyword arguments:
%    None.
%
% See also:
%    Acquisition_FlickerSensitivity_2IFC
%

% History:
%    2018-10-26  jv   wrote extractResultsFromAcquisition with collection
%                     of subfunctions

results = table();
name = split(acquisition.name,'_');
results.axis = name(1);
results.adaptationLevel = name(2);
results.quickThresholdContrast = exctractNominalThresholdContrast(acquisition);
results.fitThresholdContrast = acquisition.fitPsychometricFunctionThreshold();
results.validatedThresholdContrast = extractValidatedThresholdContrast(acquisition);
results.quickJND = quickJND(acquisition);
results.fitJND = fitJND(acquisition);
results.validatedJND = extractValidatedJND(acquisition);
end

function nominalThresholdContrast = exctractNominalThresholdContrast(acquisition)
nominalThresholdContrast = mean(acquisition.thresholds);
end

function quickJND = quickJND(acquisition)
thresholdDirection = exctractThresholdDirection(acquisition);
[~,~,excitationDiff] = thresholdDirection.ToDesiredReceptorContrast(acquisition.background, acquisition.receptors);
quickJND = excitationDiffToJND(excitationDiff);
end

function fitJND = fitJND(acquisition)
direction = acquisition.direction;
background = acquisition.background;
receptors = acquisition.receptors;

fitThresholdCont = acquisition.fitPsychometricFunctionThreshold();

targetContrasts = fitThresholdCont * [1 1 1 0; -1 -1 -1 0]';
thresholdDirection = direction.ScaleToReceptorContrast(background,receptors,targetContrasts);
[~,~,excitationDiff] = thresholdDirection.ToDesiredReceptorContrast(acquisition.background, acquisition.receptors);
fitJND = excitationDiffToJND(excitationDiff);
end

function thresholdDirection = exctractThresholdDirection(acquisition)
direction = acquisition.direction;
background = acquisition.background;
receptors = acquisition.receptors;

nominalThresholdCont = exctractNominalThresholdContrast(acquisition);

targetContrasts = nominalThresholdCont * [1 1 1 0; -1 -1 -1 0]';
thresholdDirection = direction.ScaleToReceptorContrast(background,receptors,targetContrasts);
end

function validatedThresholdContrast = extractValidatedThresholdContrast(acquisition)
validations = acquisition.validationAtThreshold;

if ~isempty(validations)
    contrast = cat(3,validations.contrastActual);
    contrast = mean(contrast,3);
    contrast = contrast(1:3,:);
    validatedThresholdContrast = mean(abs(contrast(:)));
else
    validatedThresholdContrast = NaN;
end
end

function validatedJND = extractValidatedJND(acquisition)
validations = acquisition.validationAtThreshold;

if ~isempty(validations)
    excitation = cat(3,validations.excitationActual);
    excitation = mean(excitation,3);
    excitationDiff = excitation(:,4:5);
    validatedJND = excitationDiffToJND(excitationDiff);
else
    validatedJND = NaN;
end
end

function JND = excitationDiffToJND(excitationDiff)
JND = mean(mean(abs(excitationDiff(1:3,:))));
end