# REF_SOURCE - source for gene-to-pubmed references - this must be global!
# Computes profile to profile distances between gene-mesh profiles and
# disease-mesh profiles

profile_gd_predict: 	$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt \
			$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt \
			$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-profiles.txt \
			$(PROFILE_GD_PREFIX)/disease-disease-profiles.txt \
			$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-count.txt \
                        $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-count.txt \
                        $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-count.txt \
			$(PROFILE_GD_PREFIX)/disease-pharma-chem-profiles.txt \
                        $(PROFILE_GD_PREFIX)/disease-disease-count.txt 
#			$(PROFILE_GD_PREFIX)/disease-chem-profiles.txt \
#			$(PROFILE_GD_PREFIX)/author-author-profiles.txt

profile_gd_predict_clean: 

REF_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/$(REF_SOURCE)-profile
BG_REF_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/BG-$(REF_SOURCE)-profile
BG_REF_PROFILE2_PREFIX=$(PROFILE_GD_PREFIX)/BG-$(REF_SOURCE)-profile2
DISEASE_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/disease-profile
DCHEM_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/dchem-profile
DPCHEM_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/dpchem-profile
AUTHOR_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/auth-profile

$(PROFILE_GD_PREFIX)/disease-disease-profiles.txt: \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py 
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt > $@.mk && \
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$@ >>$@.mk && \
	echo SPLIT_PREFIX=$(DISEASE_PROFILE_PREFIX)/disease-profile- >>$@.mk && \
	echo SPLIT_SUFFIX=txt  >>$@.mk && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.mk && \
	$(MAKE) -f $@.mk start


$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt: \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py 
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt > $@.mk && \
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt >>$@.mk && \
	echo SPLIT_PREFIX=$(BG_REF_PROFILE_PREFIX)/$(REF_SOURCE)-profile- >>$@.mk && \
	echo SPLIT_SUFFIX=txt  >>$@.mk && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.mk && \
	$(MAKE) -f $@.mk start

$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt > $@.mk;\
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt >>$@.mk && \
	echo SPLIT_PREFIX=$(REF_PROFILE_PREFIX)/$(REF_SOURCE)-profile- >>$@.mk  && \
	echo SPLIT_SUFFIX=txt  >>$@.mk  && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.mk && \
	$(MAKE) -f $@.mk start

# Gene-Gene

$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-profiles.txt: \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt > $@.mk && \
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-profiles.txt >>$@.mk && \
	echo SPLIT_PREFIX=$(BG_REF_PROFILE2_PREFIX)/$(REF_SOURCE)-profile- >>$@.mk  && \
	echo SPLIT_SUFFIX=txt  >>$@.mk  && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Count

$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-count.txt: $(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt
	tail -n +2 $< | wc > $@.tmp && \
	mv $@.tmp $@

$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-count.txt: $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt
	tail -n +2 $< | wc > $@.tmp && \
	mv $@.tmp $@

$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-count.txt: $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-profiles.txt
	tail -n +2 $< | wc > $@.tmp && \
	mv $@.tmp $@

$(PROFILE_GD_PREFIX)/disease-disease-count.txt: $(PROFILE_GD_PREFIX)/disease-disease-profiles.txt
	tail -n +2 $< | wc > $@.tmp && \
	mv $@.tmp $@

$(PROFILE_GD_PREFIX)/disease-chem-profiles.txt: \
		$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt > $@.mk;\
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$@ >>$@.mk && \
	echo SPLIT_PREFIX=$(DCHEM_PROFILE_PREFIX)/disease-chem-profile- >>$@.mk  && \
	echo SPLIT_SUFFIX=txt  >>$@.mk  && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.mk && \
	$(MAKE) -f $@.mk start

# Author-author
$(PROFILE_GD_PREFIX)/author-author-profiles.txt: \
		$(DIRECT_GD_PREFIX)/all-author-mesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/all-author-mesh-p.txt > $@.mk && \
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/all-author-mesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$@ >>$@.mk && \
	echo SPLIT_PREFIX=$(AUTHOR_PROFILE_PREFIX)/all-author-profile- >>$@.mk  && \
	echo SPLIT_SUFFIX=txt  >>$@.mk  && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Pharma-disease
$(PROFILE_GD_PREFIX)/disease-pharma-chem-profiles.txt: \
		$(DIRECT_GD_PREFIX)/pharma-chem-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/pharma-chem-mesh-p.txt > $@.mk;\
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt >> $@.mk && \
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.mk && \
	echo OUTPUT_FILE=$@ >>$@.mk && \
	echo SPLIT_PREFIX=$(DPCHEM_PROFILE_PREFIX)/disease-chem-profile- >>$@.mk  && \
	echo SPLIT_SUFFIX=txt  >>$@.mk  && \
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.mk && \
	$(MAKE) -f $@.mk start

# Need p-values for comesh profiles
# Use the same file as for disease?
# Compute in parse_pubmed?
