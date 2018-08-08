# Config
include config.mk

# Outline data
PARTICIPANTS = $(notdir $(wildcard $(DATA_RAW_DIR)/*) )
ACQUISITIONS = $(wildcard $(DATA_RAW_DIR)/*/*/*.mat)

# Merge participants
results_all.csv :
		@echo "execute grand merge rule"
		
# Merge sessions per participant	
results_participant-%.csv :
		@echo "execute participant rule"

# Merge acquisitions per session
# Stem (%) in target specifies both participant AND session
# Requires .SECONDEXPANSION to expand $* in prereqs
.SECONDEXPANSION:
results_session-%.csv: $$(wildcard $(DATA_PROC_DIR)/*/*/results_acquisition-$$*-*.csv)
		@echo execute merge rule $(MERGE_SRC) on CSVs: $^

# Extract acquisition results
results_acquisition-%.csv : $(CONVERT_SRC)
		@echo "execute conversion rule"
		
# Print variables
.PHONY:
variables :
		@echo PARTICIPANTS:"\n" $(foreach PARTICIPANT, $(PARTICIPANTS), $(PARTICIPANT)"\n")
		@echo ACQUISITIONS:"\n" $(foreach ACQUISITION, $(ACQUISITIONS), $(ACQUISITION)"\n")