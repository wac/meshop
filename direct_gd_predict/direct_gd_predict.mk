# Includes Gene-Disease and Disease-Disease Profiles

# Make the output "templated" so that it can build connection versions
# (gene2pubmed vs generif)
# - Then,  template the entire gene-disease process?
# ?  How to inherit the directories names?

# Command to sort - Assume working directory is safe since some of the
# files will be (very) large
#  -do NOT sort using dictionary (alphanumeric) only
# FIXME this leaves temp files that aren't deleted?!
BIGSORT=sort -T $(BIGTMP_DIR) 

ifdef TAXON_ID
TAXON_STATS=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt \
else
TAXON_STATS=
endif

direct_gd_predict: $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/all-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-disease-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-diseaseBG-disease-comesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/nr-all-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/chemBG-chem-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/all-author-min20-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/all-short-author-mesh-p.txt \
		$(TAXON_STATS) \
		$(DIRECT_GD_PREFIX)/pharma-chem-mesh-p.txt
#		$(DIRECT_GD_PREFIX)/mesh-stats.txt 

direct_gd_predict_clean: 
	rm -f $(DIRECT_GD_PREFIX)/*.txt
	rm -f $(DIRECT_GD_PREFIX)/*.txt.tmp

#$(DIRECT_GD_PREFIX)/hum-gene.txt:  $(GENE_PREFIX)/load-gene.txt
#	echo "SELECT gene_id from gene WHERE taxon_id=9606" | $(SQL_CMD) > $@.tmp
#	mv $@.tmp $@

#$(DIRECT_GD_PREFIX)/mus-gene.txt:  $(GENE_PREFIX)/load-gene.txt
#	echo "SELECT gene_id from gene WHERE taxon_id=10090" | $(SQL_CMD) > $@.tmp
#	mv $@.tmp $@

# Extract all gene ids for organism $(TAXON_NAME)
ifdef TAXON_ID
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt:  $(SQL_PREFIX)/load-gene.txt
	echo "SELECT gene_id from gene WHERE taxon_id=$(TAXON_ID)" | $(SQL_CMD) | tail -n +2  > $@.tmp && \
	mv $@.tmp $@
endif

# Get counts for all MeSH terms linked to each gene ID vis $(REF_SOURCE)
# Get around query size limitations by doing the sorting/counting outside the DB
$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt:	\
		$(SQL_PREFIX)/load-mesh-parent.txt \
		$(SQL_PREFIX)/load-gene.txt \
		$(SQL_PREFIX)/load-$(REF_SOURCE).txt
	echo "SELECT gene.gene_id, mesh_parent, $(REF_SOURCE).pmid FROM $(REF_SOURCE), gene, pubmed_mesh_parent WHERE gene.gene_id=$(REF_SOURCE).gene_id AND $(REF_SOURCE).pmid=pubmed_mesh_parent.pmid;" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,1 | uniq | cut -d "|" -f 1,2 | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Count number of pmids associated with each MeSH term
$(DIRECT_GD_PREFIX)/all-mesh-refs.txt:	\
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt
	cat $< | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Count only gene-referenced pmids for each MeSH term for $(TAXON_NAME)

ifdef TAXON_ID
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(SQL_PREFIX)/load-$(REF_SOURCE).txt \
		$(SQL_PREFIX)/load-gene.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py
	echo "SELECT pmid FROM $(REF_SOURCE), gene where $(REF_SOURCE).gene_id=gene.gene_id AND gene.taxon_id=$(TAXON_ID)" | $(SQL_CMD) | tail -n +2 | $(BIGSORT) | uniq > $@.tmp1
else
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(SQL_PREFIX)/load-$(REF_SOURCE).txt \
		$(SQL_PREFIX)/load-gene.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt \
		$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-pmids.txt
	cat $(GENE_PREFIX)/all-$(REF_SOURCE)-gene-pmids.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt | cut -d "|" -f 2 | $(BIGSORT) | uniq > $@.tmp1
endif
	cat $@.tmp1 | wc --lines > $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt && \
	cat $< | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@ ; rm $@.tmp1


# Count of the total number of pmids referenced by gene ids for $(TAXON_NAME)
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt

# Count MeSH term references for each gene in $(TAXON_NAME) via $(REF_SOURCE)
# Filter from all-$(REF_SOURCE)-gene-mesh.txt
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt
	cat $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt > $@.tmp && \
	mv $@.tmp $@

# Compute hypergeometric p-values and tfidf scores 
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
		$(SQL_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt >> $@.mk ; \
	echo PROFILE_PHYPER_TOTAL=`cat $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-count.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene-$(REF_SOURCE)-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT=  >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Count only disease-referenced pmids for each MeSH term
$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	cat $(PM_MESH_PARENT_PREFIX)/mesh-parent.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/mesh-disease.txt | cut -d "|" -f 2 | uniq > $@.tmp1
	cat $@.tmp1 | wc --lines > $(DIRECT_GD_PREFIX)/disease-mesh-count.txt && \
	cat $< | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@ ; rm $@.tmp1

# Count only brain disease-referencing pmids for each MeSH term
$(DIRECT_GD_PREFIX)/braindisease-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/mesh-braindisease.txt
	cat $(PM_MESH_PARENT_PREFIX)/mesh-parent.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/mesh-braindisease.txt | cut -d "|" -f 2 | uniq > $@.tmp1 && \
	cat $@.tmp1 | wc --lines > $(DIRECT_GD_PREFIX)/braindisease-mesh-count.txt && \
	cat $< | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@ ; rm $@.tmp1

# Total number of (unique) pmids referenced by disease MeSH terms
$(DIRECT_GD_PREFIX)/disease-mesh-count.txt: \
		$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt

# Total number of (unique) pmids referenced by brain disease MeSH
$(DIRECT_GD_PREFIX)/braindisease-mesh-count.txt: \
		$(DIRECT_GD_PREFIX)/braindisease-mesh-refs.txt

# MeSH terms associated with Disease MeSH terms
$(DIRECT_GD_PREFIX)/disease-comesh-total.txt: \
		$(PM_COMESH_PREFIX)/comesh-total.txt \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	cat $(PM_COMESH_PREFIX)/comesh-total.txt | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $(DIRECT_GD_PREFIX)/mesh-disease.txt > $@.tmp && \
	mv $@.tmp $@

# MeSH terms associated with Brain Disease MeSH terms
$(DIRECT_GD_PREFIX)/braindisease-comesh-total.txt: \
		$(PM_COMESH_PREFIX)/comesh-total.txt \
		$(DIRECT_GD_PREFIX)/mesh-braindisease.txt
	cat $(PM_COMESH_PREFIX)/comesh-total.txt | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $(DIRECT_GD_PREFIX)/mesh-braindisease.txt > $@.tmp && \
	mv $@.tmp $@

# Disease MeSHOPs using Disease PubMed as background
$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt:	\
		$(DIRECT_GD_PREFIX)/disease-mesh-count.txt \
		$(DIRECT_GD_PREFIX)/disease-comesh-total.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/disease-comesh-total.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(DIRECT_GD_PREFIX)/disease-mesh-count.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/disease-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT=-r >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk  >> $@.mk && \
	$(MAKE) -f $@.mk start

# Brain Disease MeSHOPs using brain disease pubmed as background 
$(DIRECT_GD_PREFIX)/braindiseaseBG-disease-comesh-p.txt:	\
		$(DIRECT_GD_PREFIX)/braindisease-mesh-count.txt \
		$(DIRECT_GD_PREFIX)/braindisease-comesh-total.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/braindisease-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/mesh-braindisease.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/braindisease-comesh-total.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/braindiseaseBG-disease-comesh-p.txt >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(DIRECT_GD_PREFIX)/braindisease-mesh-count.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/braindisease-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT=-r >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk  >> $@.mk &&
	$(MAKE) -f $@.mk start

# Leaf term Filtered Brain Disease (Brain Disease background) MeSHOPs
$(DIRECT_GD_PREFIX)/nr-braindiseaseBG-disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/braindiseaseBG-disease-comesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/braindiseaseBG-disease-comesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp && \
	mv $@.tmp $@

# Leaf term filtered Gene MeSHOPs
# All gene mesh reference & p value computation Makefile
$(DIRECT_GD_PREFIX)/nr-all-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $< | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp && \
	mv $@.tmp $@ 

# Leaf term filtered Gene MeSHOPs for $(TAXON_NAME)
$(DIRECT_GD_PREFIX)/nr-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp && \
	mv $@.tmp $@ 

# Leaf term filtered gene MeSHOPs for $(TAXON_NAME) ($(TAXON_NAME) background)
$(DIRECT_GD_PREFIX)/nr-$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp && \
	mv $@.tmp $@ 

# Full gene MeSHOPs for $(TAXON_NAME)
$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt
	cat $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt > $@.tmp && \
	mv $@.tmp $@

# All full gene MeSHOPs
$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(SQL_PREFIX)/load-titles.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT= >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Leaf term filtered disease MeSHOPs
$(DIRECT_GD_PREFIX)/nr-disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/disease-comesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/disease-comesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp && \
	mv $@.tmp $@

# Leaf term filtered disease MeSHOPs (disease background)
$(DIRECT_GD_PREFIX)/nr-diseaseBG-disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		$(UTIL)/filter-leaf.py
	cat $(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt | python $(UTIL)/filter-leaf.py $(MESH_PREFIX)/mesh-child.txt > $@.tmp && \
	mv $@.tmp $@

# Disease MeSHOPs
$(DIRECT_GD_PREFIX)/disease-comesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-comesh-p.txt
	cat  $(DIRECT_GD_PREFIX)/all-comesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/mesh-disease.txt > $@.tmp && \
	mv $@.tmp $@

# All MeSH term MeSHOPs
$(DIRECT_GD_PREFIX)/all-comesh-p.txt: \
		$(PM_COMESH_PREFIX)/comesh-total.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt \
		$(DIRECT_GD_PREFIX)/mesh-disease.txt
	echo PROFILE_INPUT_DATA=$(PM_COMESH_PREFIX)/comesh-total.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$(DIRECT_GD_PREFIX)/all-comesh-p.txt >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(SQL_PREFIX)/load-titles.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT=-r >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk  >> $@.mk && \
	$(MAKE) -f $@.mk start

# All terms in Category C (Disease)
$(DIRECT_GD_PREFIX)/mesh-disease.txt:	$(SQL_PREFIX)/load-mesh-tree.txt
	echo "SELECT term from mesh_tree WHERE tree_num LIKE 'C%'" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp && \
	mv $@.tmp $@

# All terms including/under the MeSH term for Brain Diseases
$(DIRECT_GD_PREFIX)/mesh-braindisease.txt:	$(SQL_PREFIX)/load-mesh-tree.txt
	echo "SELECT term from mesh_tree WHERE tree_num LIKE 'C10.228.140.%'" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp && \
	mv $@.tmp $@

# All terms including/under the MeSH term for Pharmacologic Actions
$(DIRECT_GD_PREFIX)/mesh-therapeutic.txt:	$(SQL_PREFIX)/load-mesh-tree.txt
	echo "SELECT term from mesh_tree WHERE tree_num LIKE 'D27.505.954.%'" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp && \
	mv $@.tmp $@

# REF_SOURCE bibliometric gene stats for validation
# number of refs,  oldest ref 

$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-$(REF_SOURCE)-stats.txt: \
		$(DIRECT_GD_PREFIX)/$(TAXON_NAME)-gene.txt \
		$(SQL_PREFIX)/load-$(REF_SOURCE).txt \
		$(SQL_PREFIX)/load-titles.txt
	echo "SELECT gene.gene_id, MIN(pubyear) AS oldest_year, COUNT(DISTINCT $(REF_SOURCE).pmid) AS refs FROM gene, $(REF_SOURCE), pubmed WHERE gene.gene_id=$(REF_SOURCE).gene_id AND gene.taxon_id=$(TAXON_ID) AND $(REF_SOURCE).pmid=pubmed.pmid GROUP BY gene_id" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp && \
	mv $@.tmp $@

# MeSH stats for validation 
$(DIRECT_GD_PREFIX)/mesh-stats.txt: \
                $(SQL_PREFIX)/load-mesh-parent.txt \
		$(SQL_PREFIX)/load-titles.txt
	echo "SELECT mesh_parent, MIN(pubyear) AS oldest_year, COUNT(DISTINCT pubmed.pmid) AS refs FROM pubmed_mesh_parent, pubmed WHERE pubmed_mesh_parent.pmid=pubmed.pmid GROUP BY mesh_parent" | $(SQL_CMD) | tail -n +2 | sort | uniq > $@.tmp && \
	mv $@.tmp $@

# Supplemental Chem Compounds MeSH Count
$(DIRECT_GD_PREFIX)/all-chem-mesh.txt:	\
		$(SQL_PREFIX)/load-mesh-parent.txt \
		$(SQL_PREFIX)/load-chem.txt
	echo "SELECT pubmed_chem.term, mesh_parent, pubmed_chem.pmid FROM pubmed_chem, pubmed_mesh_parent WHERE pubmed_chem.pmid=pubmed_mesh_parent.pmid;" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,1 | uniq | cut -d "|" -f 1,2 | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Total pubmed references for each Supp Chem Compound
$(DIRECT_GD_PREFIX)/all-chem-refs.txt:	$(PUBMED_CHEM_TXT)
	cat $(PUBMED_CHEM_TXT) | cut -d "|" -f 2 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# MeSHOPs for Supp Chen Compounds
$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-chem-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-chem-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-chem-mesh.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$@ >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(SQL_PREFIX)/load-titles.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-chem-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT= >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Only chem-referenced pmids for each MeSH term
$(DIRECT_GD_PREFIX)/chem-mesh-refs.txt: \
		$(PM_MESH_PARENT_PREFIX)/mesh-parent.txt \
		$(SQL_PREFIX)/load-chem.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py
	echo "SELECT pmid FROM pubmed_chem" | $(SQL_CMD) | tail -n +2 | $(BIGSORT) | uniq > $@.tmp1
	cat $@.tmp1 | wc --lines > $(DIRECT_GD_PREFIX)/chem-count.txt && \
	cat $< | python $(DIRECT_GD_PREDICT)/filter_file.py --field 1 $@.tmp1 | cut -d "|" -f 1 | $(BIGSORT) | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@ ; rm $@.tmp1

# Total number of supp chem reference pmids
$(DIRECT_GD_PREFIX)/chem-count.txt: \
		$(DIRECT_GD_PREFIX)/chem-mesh-refs.txt

# Supp Chem Compounds MeSHOPs (Supp Chem Compound bacground)
$(DIRECT_GD_PREFIX)/chemBG-chem-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-chem-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-chem-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(DIRECT_GD_PREFIX)/chem-count.txt \
		$(DIRECT_GD_PREFIX)/chem-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-chem-mesh.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$@ >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(DIRECT_GD_PREFIX)/chem-count.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-chem-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/chem-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT= >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Author MeSH term counts - lastname, firstnamme (initials)
# Normalising the author name into a single field?
$(DIRECT_GD_PREFIX)/all-author-mesh.txt:	\
		$(SQL_PREFIX)/load-mesh-parent.txt \
		$(SQL_PREFIX)/load-author.txt
	echo "select UPPER(CONCAT(lastname, ', ', forename, ' (', initials, ')')) AS name, mesh_parent from pubmed_author, pubmed_mesh_parent WHERE pubmed_author.pmid=pubmed_mesh_parent.pmid" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,1 | uniq | cut -d "|" -f 1,2 | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Abbrev Author MeSH term counts - lastname, initials
$(DIRECT_GD_PREFIX)/all-short-author-mesh.txt:	\
		$(SQL_PREFIX)/load-mesh-parent.txt \
		$(SQL_PREFIX)/load-author.txt
	echo "select UPPER(CONCAT(lastname, ', ', initials)) AS name, mesh_parent from pubmed_author, pubmed_mesh_parent WHERE pubmed_author.pmid=pubmed_mesh_parent.pmid" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,1 | uniq | cut -d "|" -f 1,2 | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Author referenced article counts
$(DIRECT_GD_PREFIX)/all-author-refs.txt:	$(SQL_PREFIX)/load-author.txt
	echo "select UPPER(CONCAT(lastname, ', ', forename, ' (', initials, ')')) AS name, pmid from pubmed_author" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,1 | uniq | cut -d "|" -f 1 | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Abbrev Author referenced article counts
$(DIRECT_GD_PREFIX)/all-short-author-refs.txt:	$(SQL_PREFIX)/load-author.txt
	echo "select UPPER(CONCAT(lastname, ', ', initials)) AS name, pmid from pubmed_author" | $(SQL_CMD) | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1,1 | uniq | cut -d "|" -f 1 | $(UNIQ_COUNT) > $@.tmp && \
	mv $@.tmp $@

# Author MeSHOPs
$(DIRECT_GD_PREFIX)/all-author-min20-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-author-mesh-p.txt
	cat $< | awk -F '|' '$$4 > 20' > $@.tmp && \
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/all-author-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-author-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-author-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-author-mesh.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$@ >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(SQL_PREFIX)/load-titles.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-author-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT= >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Abbrev Author MeSHOPs
$(DIRECT_GD_PREFIX)/all-short-author-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/all-short-author-mesh.txt \
		$(DIRECT_GD_PREDICT)/get_pval.R \
		$(DIRECT_GD_PREDICT)/get_pval.mk \
		$(DIRECT_GD_PREDICT)/merge_coc.py \
		$(DIRECT_GD_PREDICT)/filter_file.py \
		$(DIRECT_GD_PREFIX)/all-short-author-refs.txt \
		$(DIRECT_GD_PREFIX)/all-mesh-refs.txt \
		$(SQL_PREFIX)/load-titles.txt
	echo PROFILE_INPUT_DATA=$(DIRECT_GD_PREFIX)/all-short-author-mesh.txt > $@.mk && \
	echo PROFILE_OUTPUT_FILE=$@ >> $@.mk && \
	echo PROFILE_PHYPER_TOTAL=`cat $(SQL_PREFIX)/load-titles.txt` >> $@.mk && \
	echo PROFILE_GETP=$(DIRECT_GD_PREDICT)/get_pval.R >> $@.mk && \
	echo PROFILE_MERGE_COC=$(DIRECT_GD_PREDICT)/merge_coc.py >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE1=$(DIRECT_GD_PREFIX)/all-short-author-refs.txt >> $@.mk && \
	echo PROFILE_MERGE_COC_FILE2=$(DIRECT_GD_PREFIX)/all-mesh-refs.txt >> $@.mk && \
	echo PROFILE_REVERSED_INPUT= >> $@.mk && \
	echo SELF_MAKEFILE=$@.mk >> $@.mk && \
	echo include $(DIRECT_GD_PREDICT)/get_pval.mk >> $@.mk && \
	$(MAKE) -f $@.mk start

# Limit extraction to only compounds in the pharmacologic action list
$(DIRECT_GD_PREFIX)/pharma-chem.txt: \
		$(MESH_PREFIX)/mesh_pharma.txt \
		$(MESH_PREFIX)/meshsupp_pharma.txt
	cut -f 2 -d "|" $(MESH_PREFIX)/mesh_pharma.txt $(MESH_PREFIX)/meshsupp_pharma.txt | sort | uniq > $@.tmp && \
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/therapeutic-chem.txt: \
		$(DIRECT_GD_PREFIX)/mesh-therapeutic.txt \
		$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt
	cat $(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/mesh-therapeutic.txt -f 1 | cut -f 1 -d "|" | sort | uniq > $@.tmp && \
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/pharma-chem-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/pharma-chem.txt \
		$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py 
	cat $(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/pharma-chem.txt > $@.tmp && \
	mv $@.tmp $@

$(DIRECT_GD_PREFIX)/therapeutic-chem-mesh-p.txt: \
		$(DIRECT_GD_PREFIX)/therapeutic-chem.txt \
		$(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt \
		$(DIRECT_GD_PREDICT)/filter_file.py
	cat $(DIRECT_GD_PREFIX)/all-chem-mesh-p.txt | python $(DIRECT_GD_PREDICT)/filter_file.py $(DIRECT_GD_PREFIX)/therapeutic-chem.txt > $@.tmp && \
	mv $@.tmp $@
