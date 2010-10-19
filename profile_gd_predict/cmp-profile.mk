# Input datafile
# PROFILE1_DATA=gene-mesh-RData-p.txt
# PROFILE2_DATA=comesh-RData-p.txt
# PROFILE1_SPLIT_PY=split-gene-profiles.py
# CMP_PROFILE_PY=
# OUTPUT_FILE=mesh-dist-p.txt

# Intermediate Datafile prefix
# SPLIT_PREFIX=gene-profiles/gene-profile-
# SPLIT_SUFFIX=txt

# Name of the makefile for submake calls
# SELF_MAKEFILE=

# Command to join the processed files
JOIN_CMD=cat

SPLIT_FILES=$(wildcard $(SPLIT_PREFIX)*.$(SPLIT_SUFFIX))

# Processed File Output
PROCESS_PREFIX=$(SPLIT_PREFIX)
PROCESS_FILES=$(SPLIT_FILES:$(SPLIT_PREFIX)%.$(SPLIT_SUFFIX)=$(PROCESS_PREFIX)%.out)

# Command to split the input file
start:	$(SPLIT_PREFIX)done.dummy
	$(MAKE) -f $(SELF_MAKEFILE) result

$(SPLIT_PREFIX)done.dummy:	$(PROFILE1_DATA) $(PROFILE1_SPLIT_PY)
	rm -f $(SPLIT_PREFIX)*.$(SPLIT_SUFFIX) && \
	rm -f $@ && \
	python $(PROFILE1_SPLIT_PY) $(PROFILE1_DATA) $(SPLIT_PREFIX) && \
	touch $@

# Command to process the split files
$(PROCESS_PREFIX)%.out: $(SPLIT_PREFIX)%.$(SPLIT_SUFFIX)
	python $(CMP_PROFILE_PY) $(PROFILE2_DATA) $< > $@.tmp && \
	mv $@.tmp $@

# Templates for the split/processed files

$(OUTPUT_FILE): $(PROCESS_FILES)
	ls $(PROCESS_PREFIX)*.out > $@.tmp1 && \
	xargs $(JOIN_CMD) > $@.tmp < $@.tmp1 && \
	mv $@.tmp $@ ; rm $@.tmp1

result:  $(OUTPUT_FILE)
	$(MAKE) -f $(SELF_MAKEFILE) cleanup

cleanup:
	rm -f $(PROCESS_PREFIX)*.out
	rm -f $(SPLIT_PREFIX)*.$(SPLIT_SUFFIX)
	rm -f $(SPLIT_PREFIX)done.dummy
