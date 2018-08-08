# Config
include config.mk

#Empty variable, two of them with a space in between == literal space
empty := 
space := $(empty) $(empty)

# Outline data
DATAFILES := $(wildcard $(DATA_RAW_DIR)/*/*/*.mat)

ACQUISITIONIDS := $(patsubst data-%, %, $(basename $(notdir $(DATAFILES))))
SESSIONIDS := $(sort\
	$(foreach ACQUISITIONID, $(ACQUISITIONIDS),\
	$(patsubst -%, %,\
	$(subst $(space),-,\
	$(wordlist 1,2,\
	$(subst -,$(space),$(ACQUISITIONID)))))))
	
PARTICIPANTIDS := $(sort\
	$(foreach SESSIONID, $(SESSIONIDS),\
	$(patsubst $(space),-,\
	$(firstword \
	$(subst -,$(space),$(SESSIONID))))))	

ACQUISITIONFILES := $(foreach ACQUISITIONID,$(ACQUISITIONIDS),\
	$(patsubst /%, %,\
	$(subst $(space),/,\
	$(wordlist 1,2,\
	$(subst -,$(space),$(DATA_PROC_DIR)/$(ACQUISITIONID)))))/results_acquisition-$(ACQUISITIONID).csv)
SESSIONFILES := $(addsuffix .csv, $(SESSIONIDS))
PARTICIPANTFILES := $(addsuffix .csv, $(PARTICIPANTIDS))

# Extract acquisition results
results_acquisition-%.csv : $(DATA_RAW_DIR)/*/*/data-%.mat $(LIB_DIR)/$(CONVERT_SRC) 
		$(CONVERT_EXE) $< $@ 

# Merge participants
#results_all.csv :
#		@echo "execute grand merge rule"
		
# Merge sessions per participant	
#results_participant-%.csv :
#		@echo "execute participant rule"

# Merge acquisitions per session
# Stem (%) in target specifies both participant AND session
# Requires .SECONDEXPANSION to expand $* in prereqs
#.SECONDEXPANSION:
#results_session-%.csv: $$(wildcard $(DATA_PROC_DIR)/*/*/results_acquisition-$$*-*.csv)
#		@echo execute merge rule $(MERGE_SRC) on CSVs: $^


		
# Print variables
.PHONY:
variables :
		@echo DATAFILES:"\n" $(foreach DATAFILE, $(DATAFILES), $(DATAFILE)"\n")
		@echo ACQUISITIONIDS:"\n" $(foreach ACQUISITION, $(ACQUISITIONIDS), $(ACQUISITION)"\n")
		@echo SESSIONIDS:"\n" $(foreach SESSION, $(SESSIONIDS), $(SESSION)"\n")		
		@echo PARTICIPANTIDS:"\n" $(foreach PARTICIPANT, $(PARTICIPANTIDS), $(PARTICIPANT)"\n")	
		@echo ACQUISITIONFILES:"\n" $(foreach ACQUISITIONFILE, $(ACQUISITIONFILES), $(ACQUISITIONFILE)"\n")