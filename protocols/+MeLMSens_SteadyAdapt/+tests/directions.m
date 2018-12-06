classdef testDirections < matlab.unittest.TestCase
    %TESTDIRECTIONS of the MeLMSens protocol
    %   Detailed explanation goes here
    
    properties
        oneLight;
        directions;
        receptors;
    end
    
    properties (TestParameter)
        background = {'LMS_low','LMS_high','Mel_low','Mel_high'};
        flickerContrast = num2cell(0:.001:.05);
    end
    
    methods (TestClassSetup)
        function getOneLight(testCase)
            testCase.oneLight = OneLight('simulate',true,'plotWhenSimulating',false);
        end
    end
    
    methods (Test)
        function testBackground(testCase, background)
            backgroundDir = testCase.directions(background);
            OLShowDirection(backgroundDir,testCase.oneLight);
        end
        function testFlicker(testCase, background, flickerContrast)
            backgroundDir = testCase.directions(background);
            direction = testCase.directions(['FlickerDirection_' background]);
            scaledDirection = direction.ScaleToReceptorContrast(backgroundDir, testCase.receptors, flickerContrast * [1, -1; 1, -1; 1, -1; 0, 0]);
            OLShowDirection(backgroundDir+scaledDirection, testCase.oneLight);
            OLShowDirection(backgroundDir-scaledDirection, testCase.oneLight);   
        end
    end
end