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
                        $(PROFILE_GD_PREFIX)/disease-disease-count.txt



profile_gd_predict_clean: 

REF_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/$(REF_SOURCE)-profile
BG_REF_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/BG-$(REF_SOURCE)-profile
DISEASE_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/disease-profile

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
	echo SPLIT_PREFIX=$(BG_REF_PROFILE_PREFIX)/$(REF_SOURCE)-profile- >>$@.mk  && \
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

# Need p-values for comesh profiles
# Use the same file as for disease?
# Compute in parse_pubmed?
