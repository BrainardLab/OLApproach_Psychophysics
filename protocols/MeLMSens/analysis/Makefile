# Config
include config.mk

# Outline data
PARTICIPANTS = $(notdir $(wildcard $(DATA_RAW_DIR)/*) )
ACQUISITIONS = $(wildcard $(DATA_RAW_DIR)/*/*/*.mat)

# Merge participants
results_all.csv :
		@echo "execute grand merge rule"
		
# Merge sessions per participant	
results-%.csv :
		@echo "execute participant rule"

# Merge acquisitions per session
results-%-%.csv :
		@echo "execute merge rule on dir $*"

# Extract acquisition results
results-%-%-%.csv :
		@echo "execute conversion rule"
		
# Print variables
.PHONY : variables
variables :
		@echo PARTICIPANTS:"\n" $(foreach PARTICIPANT, $(PARTICIPANTS), $(PARTICIPANT)"\n")