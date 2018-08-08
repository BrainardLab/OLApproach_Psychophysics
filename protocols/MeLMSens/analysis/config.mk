# Locations
DATA_PROC_DIR=../data/processed
DATA_RAW_DIR=../data/raw
LIB_DIR=./lib

# Data to results conversion
CONVERT_SRC=dataMatToResultsCSV.m
CONVERT_EXE=$(LIB_DIR)/matlab_dataMatToResultsCSV.sh

# Munging
MUNGE_LANGUAGE=Rscript
MERGE_SRC=mergeCSVs.R
MERGE_EXE=$(MUNGE_LANGUAGE) $(LIB_DIR)$(MERGE_SRC)