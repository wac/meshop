# Set these elsewhere (parent Makefile)

# Input Datafile name (this will be split)
# PROFILE_INPUT_DATA=
# Output file name
# PROFILE_OUTPUT_FILE=
# Total for hypergeometric (Numerical value)
# PROFILE_PHYPER_TOTAL=
# R file to compute hypergeometric
# PROFILE_GETP=
# Python file to create the input file
# PROFILE_MERGE_COC=
# File containing associated values for the first field
# PROFILE_MERGE_COC_FILE1=
# File containing associated values for the second field
# PROFILE_MERGE_COC_FILE2=
# Specify -r if the input has coc value before the fields
# PROFILE_REVERSED_INPUT= 
# Location of this Makefile
# SELF_MAKEFILE=

# Intermediate Datafile prefix
SPLIT_PREFIX=$(PROFILE_OUTPUT_FILE).split
SPLIT_FILES=$(wildcard $(SPLIT_PREFIX).*.in)

# Processed File Output
PROCESS_PREFIX=$(PROFILE_OUTPUT_FILE).process
PROCESS_FILES=$(SPLIT_FILES:$(SPLIT_PREFIX).%.in=$(PROCESS_PREFIX).%.out)
#FILTERED_PROCESS_FILES=$(SPLIT_FILES:$(SPLIT_PREFIX).%.in=$(PROCESS_PREFIX).%.out.filtered)

# Command to split the input file
SPLIT_LINES=1000000

# start target will recursively invoke make to process and make the result
start: $(SPLIT_PREFIX).done.dummy
	$(MAKE) -f $(SELF_MAKEFILE) process

$(SPLIT_PREFIX).done.dummy:	$(PROFILE_INPUT_DATA)
	rm -f $(SPLIT_PREFIX).*
	rm -f $(PROCESS_FILES) 
#	rm -f $(FILTERED_PROCESS_FILES)
	cat $(PROFILE_INPUT_DATA) | split --lines=$(SPLIT_LINES) - $(SPLIT_PREFIX).
	for f in $(SPLIT_PREFIX).* ;  do mv $$f $$f.in; done 
	touch $@

# Command to process the split files
$(PROCESS_PREFIX).%.out: $(SPLIT_PREFIX).%.in 
#		$(PROFILE_GETP) $(PROFILE_MERGE_COC) \
#		$(PROFILE_MERGE_COC_FILE1) $(PROFILE_MERGE_COC_FILE2)
	python $(PROFILE_MERGE_COC) $< $(PROFILE_MERGE_COC_FILE1) $(PROFILE_MERGE_COC_FILE2) $(PROFILE_PHYPER_TOTAL) $(PROFILE_REVERSED_INPUT) > $<.tmp
	hostname > $@.host ; export PROCESS_INFILE=$<.tmp ; export PROCESS_OUTFILE=$@.tmp ; R CMD BATCH --no-save $(PROFILE_GETP) $@.log
#	$(FILTER_CMD) $(FILTER_PAT) $@.tmp > $@.filtered
	rm $<.tmp ; mv $@.tmp $@ ; rm $@.host

$(PROCESS_PREFIX).%.out.filtered: $(PROCESS_PREFIX).%.out


# Command to join the processed files
JOIN_CMD=cat

# Templates for the split/processed files
process: $(PROCESS_FILES)
	$(MAKE) -f $(SELF_MAKEFILE) result

result:  $(PROFILE_OUTPUT_FILE) #$(FILTERED_OUTPUT_FILE)
	$(MAKE) -f $(SELF_MAKEFILE) cleanup

$(PROFILE_OUTPUT_FILE):	$(PROCESS_FILES) 
	$(JOIN_CMD) $(PROCESS_FILES) > $(PROFILE_OUTPUT_FILE).tmp
	mv $(PROFILE_OUTPUT_FILE).tmp $(PROFILE_OUTPUT_FILE)

# Filtered Process files are generated when the process files are made
#$(FILTERED_OUTPUT_FILE):	$(FILTERED_PROCESS_FILES) 
#	$(JOIN_CMD) $(FILTERED_PROCESS_FILES) > $(FILTERED_OUTPUT_FILE).tmp
#	mv $(FILTERED_OUTPUT_FILE).tmp $(FILTERED_OUTPUT_FILE)

cleanup:
	rm -f $(SPLIT_FILES) 
	rm -f $(PROCESS_FILES) 
#	rm -f $(FILTERED_PROCESS_FILES)
	rm -f $(SPLIT_PREFIX).done.dummy
