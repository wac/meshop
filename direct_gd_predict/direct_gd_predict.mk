# Includes Gene-Disease and Disease-Disease Profiles

# Make the output "templated" so that it can build connection versions
# (gene2pubmed vs generif)
# - Then,  template the entire gene-disease process?
# ?  How to inherit the directories names?

# Command to get uniq -c as pipe-delimited format =>  line|count 
UNIQ_COUNT=uniq -c | sed -r 's/^[[:blank:]]*([[:digit:]]*)[[:blank:]]*([[:print:]]*)/\2\|\1/'

# Command to remove blank lines from output
SED_RM_BLANK=sed '/^$$/d'

# Command to sort - Assume working directory is safe since some of the
# files will be (very) large
#  -do NOT sort using dictionary (alphanumeric) only
# FIXME this leaves temp files that aren't deleted?!
BIGSORT=sort -T $(BIGTMP_DIR) 

direct_gd_predict: $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/all-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-disease-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt \


direct_gd_predict_clean: 
	rm -f $(DIRECT_GD_PREFIX)/*.txt
	rm -f $(DIRECT_GD_PREFIX)/*.txt.tmp

#$(DIRECT_GD_PREFIX)/hum-gene.txt:  $(GENE_PREFIX)/load_gene.txt
#	echo "SELECT gene_id from gene WHERE taxon_id=9606" | $(SQL_CMD) > $@.tmp
#	mv $@.tmp $@

#$(DIRECT_GD_PREFIX)/mus-gene.txt:  $(GENE_PREFIX)/load_gene.txt
#	echo "SELECT gene_id from gene WHERE taxon_id=10090" | $(SQL_CMD) > $@.tmp
#	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt:  $(GENE_PREFIX)/load_gene.txt
	echo "SELECT gene_id from gene WHERE taxon_id=$(TAXON_ID)" | $(SQL_CMD) | tail -n +2  > $@.tmp
	mv $@.tmp $@


# Get around query size limitations by doing the sorting/counting outside the DB
$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt:	\
		$(PM_MESH_PARENT_PREFIX)/load-mesh-parent.txt \
		$(GENE_PREFIX)/load_gene.txt \
		$(GENE_PREFIX)/load_$(REF_SOURCE).txt
	echo "SELECT $(REF_SOURCE).gene_id, mesh_parent, $(REF_SOURCE).pmid FROM $(REF_SOURCE), pubmed_mesh_parent WHERE $(REF_SOURCE).pmid=pubmed_mesh_parent.pmid;" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,2 | uniq | cut -d "|" -f 1,2 | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/all-mesh-refs.txt:	\
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt
	cat $< | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@

# Only gene-referenced pmids
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py
	echo "SELECT pmid FROM $(REF_SOURCE), gene where $(REF_SOURCE).gene_id=gene.gene_id AND gene.taxon_id=$(TAXON_ID)" | $(SQL_CMD) | tail -n +2 | $(BIGSORT) | uniq > $@.tmp1
	cat $@.tmp1 | wc --lines > $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt
	cat $< | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@ ; rm $@.tmp1

$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt

# hum gene-mesh (no p values)
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt
	cat $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.mk \
		$(PM_TITLES_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh.txt > $@.mk ; \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt >> $@.mk ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt` >> $@.mk ; \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk ; \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk ; \
	echo PROFILE_MERGE_COC_FILE1=$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt >> $@.mk ;\
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt >> $@.mk ; \
	echo PROFILE_REVERSED_INPUT=  >> $@.mk ; \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk 
	$(MAKE) -f $@.mk split
	$(MAKE) -f $@.mk result 
	$(MAKE) -f $@.mk cleanup

# Only disease-referenced pmids
# Direct parse from the pubmed-mesh
$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py 
	cat $(PM_MESH_PARENT_PREFIX)/mesh-parent.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/mesh-disease.txt | cut -d "|" -f 2 | uniq > $@.tmp1
	cat $@.tmp1 | wc --lines > $(DIRECT_GD_PREFIX)/disease-mesh-count.txt
	cat $< | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@ ; rm $@.tmp1

$(DIRECT_GD_PREFIX)/disease-mesh-count.txt: \
		$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt

$(DIRECT_GD_PREFIX)/disease-comesh-total.txt: \
		$(PM_COMESH_PREFIX)/comesh-total.txt
	cat $(PM_COMESH_PREFIX)/comesh-total.txt | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $(DIRECT_GD_PREFIX)/mesh-disease.txt > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt:	\
		$(DIRECT_GD_PREFIX)/disease-mesh-count.txt \
		$(DIRECT_GD_PREFIX)/disease-comesh-total.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt \
		$(PM_TITLES_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-total.txt > $@.mk ; \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt >> $@.mk ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(DIRECT_GD_PREFIX)/disease-mesh-count.txt` >> $@.mk ; \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk ; \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk ; \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk ;\
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt >> $@.mk ;\
	echo PROFILE_REVERSED_INPUT=-r >> $@.mk ;\
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk  >> $@.mk
	$(MAKE) -f $@.mk split
	$(MAKE) -f $@.mk result 
	$(MAKE) -f $@.mk cleanup

# All gene mesh reference & p value computation Makefile
$(DIRECT_GD_PREFIX)/nr-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp
	mv $@.tmp $@ 

$(DIRECT_GD_PREFIX)/nr-$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp
	mv $@.tmp $@ 

$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt
	cat $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(PM_TITLES_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt > $@.mk ; \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt >> $@.mk ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(PM_TITLES_PREFIX)/load-titles.txt` >> $@.mk ; \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk ; \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk ; \
	echo PROFILE_MERGE_COC_FILE1=$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt >> $@.mk ;\
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk ; \
	echo PROFILE_REVERSED_INPUT=  >> $@.mk ; \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk 
	$(MAKE) -f $@.mk split
	$(MAKE) -f $@.mk result 
	$(MAKE) -f $@.mk cleanup

$(DIRECT_GD_PREFIX)/nr-disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/disease-comesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp
	mv $@.tmp $@


$(DIRECT_GD_PREFIX)/disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-comesh-p.txt
	cat  $(DIRECT_GD_PREFIX)/all-comesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/mesh-disease.txt > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/all-comesh-p.txt:
		$(PM_COMESH_PREFIX)/comesh-total.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(PM_TITLES_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo PROFILE_INPUT_DATA=$(PM_COMESH_PREFIX)/comesh-total.txt > $@.mk ; \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/all-comesh-p.txt >> $@.mk ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(PM_TITLES_PREFIX)/load-titles.txt` >> $@.mk ; \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk ; \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk ; \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk ;\
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk ;\
	echo PROFILE_REVERSED_INPUT=-r >> $@.mk ;\
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk  >> $@.mk
	$(MAKE) -f $@.mk split
	$(MAKE) -f $@.mk result 
	$(MAKE) -f $@.mk cleanup

$(DIRECT_GD_PREFIX)/mesh-disease.txt:	$(MESH_PREFIX)/load-mesh-tree.txt
	echo "SELECT term from mesh_tree WHERE tree_num LIKE 'C%'" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp
	mv $@.tmp $@

# REF_SOURCE stats for validation 
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt:	\
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt \
		$(GENE_PREFIX)/load_$(REF_SOURCE).txt \
		$(DIRECT_GD_PREDICT)/get_gene_stats.sh \
		$(PUBMED_PREFIX)/titles/load-titles.txt
#	cat $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt | sh $(DIRECT_GD_PREDICT)/get_gene_stats.sh $(REF_SOURCE) "$(SQL_CMD)" > $@.tmp
#	mv $@.tmp $@
	echo "SELECT gene.gene_id, MIN(pubyear) AS oldest_year, COUNT(DISTINCT $(REF_SOURCE).pmid) AS refs FROM gene, $(REF_SOURCE), pubmed WHERE gene.gene_id=$(REF_SOURCE).gene_id AND gene.taxon_id=$(TAXON_ID) AND $(REF_SOURCE).pmid=pubmed.pmid GROUP BY gene_id" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp
	mv $@.tmp $@
