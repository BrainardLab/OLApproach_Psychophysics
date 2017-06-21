function [params, block] = initParamsAndGenerateBlock(exp)
    % params = initParams(exp)
    % Initialize the parameters

    [~, tmp, suff] = fileparts(exp.configFileName);
    exp.configFileName = fullfile(exp.configFileDir, [tmp, suff]);

    % Load the config file for this condition.
    cfgFile = ConfigFile(exp.configFileName);

    % Convert all the ConfigFile parameters into simple struct values.
    params = convertToStruct(cfgFile);
    params.cacheDir = getpref('OneLight', 'cachePath');

    % Load the calibration file.
    cType = OLCalibrationTypes.(params.calibrationType);
    params.oneLightCal = LoadCalFile(cType.CalFileName);

    % Setup the cache.
    params.olCache = OLCache(params.cacheDir, params.oneLightCal);

    file_names = allwords(params.modulationFiles,',');
    for i = 1:length(file_names)
        % Create the cache file name.
        [~, params.cacheFileName{i}] = fileparts(file_names{i});
    end
    params.protocolName = exp.protocolList(exp.protocolIndex).dataDirectory;
    params.obsIDAndRun = exp.obsIDAndRun;
    params.obsID = exp.subject;
    
    fprintf('> Trial numbers in protocol file:\n');
    fprintf('   nTrials: %g\n', params.nTrials);
    fprintf('   theFrequencyIndices: %g\n', length(params.theFrequencyIndices));
    fprintf('   thePhaseIndices: %g\n', length(params.thePhaseIndices));
    fprintf('   theDirections: %g\n', length(params.theDirections));
    fprintf('   theContrastRelMaxIndices: %g\n', length(params.theContrastRelMaxIndices));
    fprintf('   trialDuration: %g\n\n', length(params.trialDuration));

    % Ask for the observer age
    params.observerAgeInYears = GetWithDefault('>>> Observer age', 32);

    % Ask if we want to skip pupil recording in the first trial
    params.skipPupilRecordingFirstTrial = false;

    modulationPath = getpref('OneLight', 'modulationPath');
    
    % Put together the trial order
    for i = 1:length(params.cacheFileName)
        % Construct the file name to load in age-specific file

        %modulationData{i} = LoadCalFile(params.cacheFileName{i}, [], [params.cacheDir '/modulations/']);
        [~, fileName, fileSuffix] = fileparts(params.cacheFileName{i});
        %params.cacheFileName{i} = [fileName '-' exp.subject fileSuffix];
        if isempty(strfind(params.protocolName, 'Screening'))
            params.cacheFileName{i} = [fileName '-' num2str(params.observerAgeInYears) '_' params.obsID '_' datestr(now, 'mmddyy') fileSuffix];
        else
            params.cacheFileName{i} = [fileName '-' num2str(params.observerAgeInYears) fileSuffix];
        end
        try
            modulationData{i} = load(fullfile(modulationPath, params.cacheFileName{i}));
        catch
            error('ERROR: Cache file for observer with specific age or nulling ID could not be found');
        end
    end

    % Put together the trial order
    % Pre-initialize the blocks
    block = struct();
    block(params.nTrials).describe = '';

    % Debug
    %params.nTrials = 1;

    params.whichTrialToStartAt = GetWithDefault('Which trial to start at?', 1);

    for i = 1:params.nTrials
        fprintf('- Preconfiguring trial %i/%i...', i, params.nTrials);
        block(i).data = modulationData{params.theDirections(i)}.modulationObj.modulation(params.theFrequencyIndices(i), params.thePhaseIndices(i), params.theContrastRelMaxIndices(i));
        block(i).describe = modulationData{params.theDirections(i)}.modulationObj.describe;

        % Check if the 'attentionTask' flag is set. If it is, set up the task
        % (brief stimulus offset).
        %block(i).attentionTask.flag = params.attentionTask(i);
        block(i).modulationMode = block(i).data.modulationMode;
        if ~isempty(strfind(block(i).modulationMode, 'pulse'))
            block(i).direction = block(i).data.direction;
            block(i).contrastRelMax = block(i).describe.theContrastRelMax(params.theContrastRelMaxIndices(i));
            block(i).carrierFrequencyHz = -1;
            block(i).carrierPhaseDeg = -1;
            block(i).phaseRandSec = block(i).data.phaseRandSec;
            block(i).stepTimeSec = block(i).data.stepTimeSec;
            block(i).preStepTimeSec = block(i).data.preStepTimeSec;
        else
            block(i).direction = block(i).data.direction;
            block(i).carrierFrequencyHz = block(i).describe.theFrequenciesHz(params.theFrequencyIndices(i));
            block(i).carrierPhaseDeg = block(i).describe.thePhasesDeg(params.thePhaseIndices(i));
            block(i).contrastRelMax = block(i).describe.theContrastRelMax(params.theContrastRelMaxIndices(i));
        end

        if strcmp(block(i).modulationMode, 'AM')
            block(i).envelopeFrequencyHz = block(i).data.theEnvelopeFrequencyHz;
            block(i).envelopePhaseDeg = block(i).carrierPhaseDeg;
            block(i).carrierPhaseDeg = 0;
        end

        if strcmp(block(i).direction, 'Background')
            block(i).modulationMode = 'BG';
            block(i).envelopePhaseDeg = 0;
            block(i).envelopeFrequencyHz = 0;
        end


        % We pull out the background.
        block(i).data.startsBG = block(i).data.background.starts;
        block(i).data.stopsBG = block(i).data.background.stops;

        fprintf('Done\n');
    end

    % Get rid of modulationData struct
    clear modulationData;
end