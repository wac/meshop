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
		$(DIRECT_GD_PREFIX)/all-comesh-p.txt 

direct_gd_predict_clean: 
	rm -f $(DIRECT_GD_PREFIX)/*.txt
	rm -f $(DIRECT_GD_PREFIX)/*.txt.tmp


# Get around query size limitations by doing the sorting/counting outside the DB
$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt:	\
		$(PM_MESH_PARENT_PREFIX)/load-mesh-parent.txt \
		$(GENE_PREFIX)/load_gene.txt \
		$(GENE_PREFIX)/load_$(REF_SOURCE).txt
	echo "SELECT $(REF_SOURCE).gene_id, mesh_parent, $(REF_SOURCE).pmid FROM $(REF_SOURCE), pubmed_mesh_parent WHERE $(REF_SOURCE).pmid=pubmed_mesh_parent.pmid;" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,2 | uniq | cut -d "|" -f 1,2 | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/all-mesh-refs.txt:	\
		$(PM_MESH_PARENT_PREFIX)/load-mesh-parent.txt
	echo "SELECT mesh_parent AS term, pmid FROM pubmed_mesh_parent;" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" > $@.tmp1
	cat $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.mk:	\
		$(PM_TITLES_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREDICT)/get_pval.mk
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt > $@.tmp ; \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt >> $@.tmp ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(PM_TITLES_PREFIX)/load-titles.txt` >> $@.tmp ; \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.tmp ; \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.tmp ; \
	echo PROFILE_MERGE_COC_FILE1=$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt >> $@.tmp ;\
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.tmp ; \
	echo PROFILE_REVERSED_INPUT=  >> $@.tmp ; \
	echo FILTER_PAT=$(DIRECT_GD_PREFIX)/hum-gene.txt  >> $@.tmp ;\
	echo FILTERED_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/hum-$(REF_SOURCE)-gene-mesh-p.txt  >> $@.tmp ;\
	echo FILTER_CMD=python $(DIRECT_GD_PREDICT)/filter_file.py >> $@.tmp ;\
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.tmp 
	mv $@.tmp $@


$(DIRECT_GD_PREFIX)/hum-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt

$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.mk \
		$(PM_TITLES_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/hum-gene.txt
	$(MAKE) -f $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.mk split
	$(MAKE) -f $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.mk result 
	$(MAKE) -f $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.mk cleanup

$(DIRECT_GD_PREFIX)/all-comesh-p.mk:	\
		$(PM_TITLES_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREDICT)/get_pval.mk
	echo PROFILE_INPUT_DATA=$(PM_COMESH_PREFIX)/comesh-total.txt > $@.tmp ; \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/all-comesh-p.txt >> $@.tmp ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(PM_TITLES_PREFIX)/load-titles.txt` >> $@.tmp ; \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.tmp ; \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.tmp ; \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.tmp ;\
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.tmp ;\
	echo PROFILE_REVERSED_INPUT=-r >> $@.tmp ;\
	echo FILTER_PAT=$(DIRECT_GD_PREFIX)/mesh-disease.txt >> $@.tmp;\
	echo FILTERED_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/disease-comesh-p.txt  >> $@.tmp ;\
	echo FILTER_CMD=python $(DIRECT_GD_PREDICT)/filter_file.py  >> $@.tmp ;\
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk  >> $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-comesh-p.txt

$(DIRECT_GD_PREFIX)/all-comesh-p.txt:
		$(PM_COMESH_PREFIX)/comesh-total.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/all-comesh-p.mk \
		$(PM_TITLES_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	$(MAKE) -f $(DIRECT_GD_PREFIX)/all-comesh-p.mk split
	$(MAKE) -f $(DIRECT_GD_PREFIX)/all-comesh-p.mk result 
	$(MAKE) -f $(DIRECT_GD_PREFIX)/all-comesh-p.mk cleanup

$(DIRECT_GD_PREFIX)/mesh-disease.txt:	$(MESH_PREFIX)/load-mesh-tree.txt
	echo "SELECT term from mesh_tree WHERE tree_num LIKE 'C%'" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/hum-gene.txt:  $(GENE_PREFIX)/load_gene.txt
	echo "SELECT gene_id from gene WHERE taxon_id=9606" | $(SQL_CMD) > $@.tmp
	mv $@.tmp $@



