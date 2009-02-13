# REF_SOURCE - source for gene-to-pubmed references - this must be global!
# Computes profile to profile distances between gene-mesh profiles and
# disease-mesh profiles

profile_gd_predict: 	$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt \
			$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt

profile_gd_predict_clean: 

REF_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/$(REF_SOURCE)-profile
BG_REF_PROFILE_PREFIX=$(PROFILE_GD_PREFIX)/BG-$(REF_SOURCE)-profile

$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt: \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py \
		$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk
	$(MAKE) -f $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk split
	$(MAKE) -f $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk result
	$(MAKE) -f $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk cleanup

$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk: \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt > $@.tmp;\
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt >> $@.tmp;\
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.tmp ;\
	echo OUTPUT_FILE=$(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt >>$@.tmp ;\
	echo SPLIT_PREFIX=$(BG_REF_PROFILE_PREFIX)/$(REF_SOURCE)-profile- >>$@.tmp  ;\
	echo SPLIT_SUFFIX=txt  >>$@.tmp  ;\
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.tmp ;\
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.tmp  
	mv $@.tmp $@

$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(PROFILE_GD_PREDICT)/cmp-profile.py \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk \
		$(PROFILE_GD_PREDICT)/split-gene-profiles.py \
		$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk
	$(MAKE) -f $(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk split
	$(MAKE) -f $(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk result
	$(MAKE) -f $(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk cleanup

$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.mk: \
		$(PROFILE_GD_PREDICT)/cmp-profile.mk
	echo PROFILE1_DATA=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt > $@.tmp;\
	echo PROFILE2_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt >> $@.tmp;\
	echo PROFILE1_SPLIT_PY=$(PROFILE_GD_PREDICT)/split-gene-profiles.py >> $@.tmp ;\
	echo OUTPUT_FILE=$(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt >>$@.tmp ;\
	echo SPLIT_PREFIX=$(REF_PROFILE_PREFIX)/$(REF_SOURCE)-profile- >>$@.tmp  ;\
	echo SPLIT_SUFFIX=txt  >>$@.tmp  ;\
	echo CMP_PROFILE_PY=$(PROFILE_GD_PREDICT)/cmp-profile.py  >>$@.tmp ;\
	echo include $(PROFILE_GD_PREDICT)/cmp-profile.mk >>$@.tmp  
	mv $@.tmp $@

# Need p-values for comesh profiles
# Use the same file as for disease?
# Compute in parse_pubmed?
# Use python rather than join?