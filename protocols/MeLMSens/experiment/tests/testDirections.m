classdef testDirections < matlab.unittest.TestCase
    %TESTDIRECTIONS of the MeLMSens protocol
    %   Detailed explanation goes here
    
    properties
        oneLight;
        directions;
        receptors;
    end
    
    methods (TestClassSetup)
        function getOneLight(testCase)
            testCase.oneLight = OneLight('simulate',true,'plotWhenSimulating',false);
        end
    end
    
    methods (Test)
        function testBackgroundLMS_high(testCase)
            background = testCase.directions('LMS_high');
            OLShowDirection(background,testCase.oneLight);
        end
    end
end