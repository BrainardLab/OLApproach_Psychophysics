#!/bin/bash
matlab_exec=/Applications/MATLAB_R2018a.app/bin/matlab

${matlab_exec} -nodisplay -nosplash -r "cd('lib'); dataMatToResultsCSV('../${1}','../${2}'); quit"