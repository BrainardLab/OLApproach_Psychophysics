# Config
include config.mk



#Empty variable, two of them with a space in between == literal space
empty := 
space := $(empty) $(empty)

# Outline data (= .mat) files
DATAFILES := $(wildcard $(DATA_RAW_DIR)/*/*/*.mat)
DATAFILENAMES := $(notdir $(DATAFILES))
DATAFILEPATHS := $(dir $(DATAFILES))

# Outline results_acquisition-*.csv files
ACQUISITIONFILENAMES := $(subst data-,results_acquisition-,\
	$(subst $(DATA_RAW_DIR),$(DATA_PROC_DIR),\
	$(subst .mat,.csv,$(DATAFILENAMES))))
ACQUISITIONFILEPATHS := $(subst $(DATA_RAW_DIR),$(DATA_PROC_DIR),$(DATAFILEPATHS))

# Extract acquisition results
#results_acquisition-%.csv : $(DATA_RAW_DIR)/*/*/data-%.mat $(LIB_DIR)/$(CONVERT_SRC) 
#		$(CONVERT_EXE) $< $@

# Define session file paths
SESSIONFILENAMES := $(sort\
	$(subst -results_acquisition-,results_session-,\
	$(foreach ACQUISITION, $(ACQUISITIONFILENAMES),\
	$(subst $(space),-,\
	$(wordlist 1,3,\
	$(subst -,$(space),$(ACQUISITION)))).csv)))
SESSIONFILEPATHS := $(sort $(ACQUISITIONFILEPATHS))
SESSIONFILES := $(join $(SESSIONFILEPATHS),$(SESSIONFILENAMES))

# Define participant paths
PARTICIPANTFILENAMES := $(sort\
  $(subst -results_session-,results_participant-,\
  $(foreach SESSION,$(SESSIONFILENAMES),\
  $(subst $(space),-,\
  $(wordlist 1,2,\
  $(subst -,$(space),$(SESSION)))).csv)))
PARTICIPANTFILEPATHS := $(sort\
	$(patsubst /%,%/,\
	$(foreach SESSIONFILE,$(SESSIONFILEPATHS),\
	$(subst $(space),/,\
	$(wordlist 1,4,\
	$(subst /,$(space),$(SESSIONFILE)))))))
PARTICIPANTFILES := $(join $(PARTICIPANTFILEPATHS),$(PARTICIPANTFILENAMES))

# First target: results_all.csv
.PHONY : results participants sessions
	results : $(DATA_PROC_DIR)/results_all.csv
	sessions : $(SESSIONFILES)
	participants : $(PARTICIPANTFILES)

$(DATA_PROC_DIR)/results_all.csv : $(PARTICIPANTFILES)
	$(MERGE_EXE) --nocol $^ > $@

.SECONDEXPANSION:
results_participant-%.csv: $(SESSIONFILES)
	$(MERGE_EXE) --nocol $^ > $@
	
.SECONDEXPANSION:
results_session-%.csv: $$(wildcard $(DATA_PROC_DIR)/*/*/results_acquisition-$$*-*.csv)
		$(MERGE_EXE) $^ > $@

# Clean
.PHONY: clean
clean:
		rm -rf $(SESSIONFILES) $(PARTICIPANTFILES) $(DATA_PROC_DIR)/results_all.csv

# Print variables
.PHONY: variables
variables :
		@echo DATAFILES:"\n" $(foreach DATAFILE, $(DATAFILES), $(DATAFILE)"\n")
		@echo DATAFILENAMES:"\n" $(foreach DATAFILE, $(DATAFILENAMES), $(DATAFILE)"\n")
		@echo DATAFILEPATHS:"\n" $(foreach DATAFILE, $(DATAFILEPATHS), $(DATAFILE)"\n")
		@echo ACQUISITIONFILENAMES:"\n" $(foreach ACQUISITIONFILE, $(ACQUISITIONFILENAMES), $(ACQUISITIONFILE)"\n")
		@echo ACQUISITIONFILEPATHS:"\n" $(foreach ACQUISITIONFILE, $(ACQUISITIONFILEPATHS), $(ACQUISITIONFILE)"\n")		
		@echo SESSIONFILENAMES:"\n" $(foreach SESSION, $(SESSIONFILENAMES), $(SESSION)"\n")		
		@echo SESSIONFILEPATHS:"\n" $(foreach SESSION, $(SESSIONFILEPATHS), $(SESSION)"\n")		
		@echo SESSIONFILES:"\n" $(foreach SESSION, $(SESSIONFILES), $(SESSION)"\n")	
		@echo PARTICIPANTFILENAMES:"\n" $(foreach PARTICIPANT, $(PARTICIPANTFILENAMES), $(PARTICIPANT)"\n")	
		@echo PARTICIPANTFILEPATHS:"\n" $(foreach PARTICIPANT, $(PARTICIPANTFILEPATHS), $(PARTICIPANT)"\n")			
		@echo PARTICIPANTFILES:"\n" $(foreach PARTICIPANT, $(PARTICIPANTFILES), $(PARTICIPANT)"\n")	
.PHONY: test
test :
	@echo $(DATA_PROC_DIR)/results_all.csv