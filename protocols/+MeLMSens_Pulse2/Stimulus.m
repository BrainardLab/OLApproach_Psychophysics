classdef Stimulus < handle
    %STIMULUS Summary of this class goes here
    %   TODO: doc
    
    properties % Modulations
        targetModulation;
        referenceModulation;
        preModulation;
        postModulation;
        interstimulusModulation;
        targetInterval; % Which interval(s) contain target modulation
    end
    
    properties (Constant) % Timing
        nIntervals(1,1) {mustBePositive, mustBeReal, mustBeFinite} = 2;     % Number of intervals
    end
    
    properties (Dependent)
        intervals;
        modulations;
    end
    
    methods
        function targetInterval = get.targetInterval(obj)
            if isempty(obj.targetInterval)
                obj.targetInterval = randi(obj.nIntervals);
            end
            targetInterval = obj.targetInterval;
        end
        
        function intervals = get.intervals(obj)
            % Get intervals of stimulus object
            %
            % Syntax:
            %   stimulus.intervals
            %
            % Description:
            %    The Stimulus-class makes a distinction between modulations
            %    (objects/structs defining how directions of primary values
            %    time-vary), and intervals, which have a experiment-level
            %    interpretation. Intervals are either a target interval, or
            %    a reference interval.
            %
            %    The intervals property returns an Nx1 (where N is the
            %    number of intervals)  struct array with fields
            %       targetPresent: boolean indicating whether this interval
            %                      contains a target,
            %
            %    This is an abstraction from the modulations property,
            %    which returns a struct array containing all modulations,
            %    including the interstimulus modulations, and the pre- and
            %    post-modulations that are shown before and after any
            %    intervals, respectively.
            %
            % See also:
            %    .modulations, .nIntervals, .targetInterval
            % See also:
            %    .nIntervals, .targetInterval
            
            % History:
            %    02/19/19  jv   wrote MeLMSuper.Stimulus.get.intervals
            
            % Initialize all as target-absent intervals, containing the
            % reference modulation
            intervals = struct('targetPresent',repmat({false},[obj.nIntervals,1]),...
                'modulation',repmat({obj.referenceModulation},[obj.nIntervals,1]));
            
            % Assign target interval
            intervals(obj.targetInterval).targetPresent = true;
            intervals(obj.targetInterval).modulation = obj.targetModulation;
        end
        
        function modulations = get.modulations(obj)
            % Get modulations of stimulus object
            %
            % Syntax:
            %   stimulus.modulations
            %
            % Description:
            %    The Stimulus-class makes a distinction between modulations
            %    (objects/structs defining how directions of primary values
            %    time-vary), and intervals, which have a experiment-level
            %    interpretation. Intervals are either a target interval, or
            %    a reference interval.
            %
            %    The modulations property returns an 1xM (where M is the
            %    number of modulations), where each struct contains the
            %    fields returned by OLAssembleModulation, as well as the
            %    boolean field 'beep' to indicate whether an auditory beep
            %    should be played at the start of this modulation.
            %    Generally, M will be 1+N+N-1+1 where N is the number of
            %    intervals (stimulus.nIntervals), since there is a
            %    pre-modulation, N target modulations, N-1 interstimulus
            %    modulations, and 1 post-modulation.
            %
            %    The modulations property is a lowerlevel, concerete
            %    implementation of the what is described by the .intervals
            %    property; the modulation-structs contain starts and stops
            %    that can be sent to OLFlicker.
            %
            % See also:
            %    .modulations, OLAssembleModulation, OLFlicker
            
            % History:
            %    02/19/19  jv   wrote MeLMSuper.Stimulus.get.intervals
            
            % Make single call to get.intervals
            intervals = obj.intervals;
            
            % Fence post 1st interval modulation
            modulations = intervals(1).modulation;
            
            % Add ISModulation, 2nd interval, ISModulation,... Nth
            % interval modulation
            for i = 2:length(intervals)
                modulations = [modulations obj.interstimulusModulation];
                modulations = [modulations intervals(i).modulation];
            end
            
            % Prepend pre modulation
            modulations = [obj.preModulation modulations];
            
            % Postpend post modulation
            modulations = [modulations obj.postModulation];
        end
        
        function show(obj, oneLight, pSpot)
            % Display this stimulus on given OneLight and projector stimulus
            %
            % Syntax:
            %   stimulus.show(OneLight, pSpot)
            %   show(stimulus, OneLight, pSpot)
            %
            % Description:
            %    Sends all modulations to the given OneLight and projector, in order,
            %    without pause. If modulations define beeps, those will be
            %    played as well.
            %
            % Inputs:
            %    stimulus - object of class 'Stimulus'.
            %    oneLight - a OneLight object to control a OneLight device.
            %
            % Outputs:
            %    None.
            %
            % See also:
            %    OLFlicker
            
            % History:
            %    07/18/18  jv   wrote Trial_NIFC
            %    02/18/19  jv   extracted stub MeLMSuper.Stimulus
            %    02/19/19  jv   extracted MeLMSuper.Stimulus.show
            
            %% Make single call to get modulations
            % obj.modulations is a dependent property: the modulations are constructed
            % on demand (which ensures that everything is correct at runtime). However,
            % we don't want to make multiple calls to it, because that takes cycles.
            % Instead, store in a local variable.
            modulations = obj.modulations;
            
            %% Run through modulations
            for m = modulations
                if isa(m,'OLModulation')
                    m.show(oneLight);
                elseif isa(m,'projectorSpot.DisplayObjectModulation')
                    m.show(pSpot.annulus);
                end
            end
            
        end
    end
end