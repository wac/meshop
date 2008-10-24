# ADD HISTOGRAM genes per pmid,  pmid per gene

gene_parse:	$(GENE_PREFIX)/gene_info $(GENE_PREFIX)/gene2pubmed \
		$(GENE_PREFIX)/parsed_basic_rif.txt \
		$(GENE_PREFIX)/load_gene.txt \
		$(GENE_PREFIX)/load_gene2pubmed.txt \
		$(GENE_PREFIX)/load_generif.txt

$(GENE_PREFIX)/gene_info: $(GENE_DIR)/DATA/gene_info.gz
	zcat $(GENE_DIR)/DATA/gene_info.gz > $@.tmp
	mv -f $@.tmp $@

$(GENE_PREFIX)/gene2pubmed: $(GENE_DIR)/DATA/gene2pubmed.gz
	zcat $(GENE_DIR)/DATA/gene2pubmed.gz > $@.tmp
	mv -f $@.tmp $@

$(GENE_PREFIX)/parsed_basic_rif.txt: $(GENE_DIR)/GeneRIF/generifs_basic.gz \
		$(GENE_PARSE)/expandRIF.py
	zcat $(GENE_DIR)/GeneRIF/generifs_basic.gz | python $(GENE_PARSE)/expandRIF.py - > $@.tmp
	mv -f $@.tmp $@

$(GENE_PREFIX)/load_gene.txt:	$(GENE_PARSE)/gene_tables.sql $(GENE_PREFIX)/gene_info
	cat $(GENE_PARSE)/gene_tables.sql | $(SQL_CMD)
	echo "DELETE FROM gene" | $(SQL_CMD)
	echo "LOAD DATA LOCAL INFILE '$(GENE_PREFIX)/gene_info' INTO TABLE gene IGNORE 1 lines (taxon_id, gene_id, locus);" | $(SQL_CMD) > $@.tmp
	mv -f $@.tmp $@

$(GENE_PREFIX)/load_gene2pubmed.txt:	$(GENE_PARSE)/gene_tables.sql $(GENE_PREFIX)/gene2pubmed
	cat $(GENE_PARSE)/gene_tables.sql | $(SQL_CMD)
	echo "DELETE FROM gene2pubmed" | $(SQL_CMD)
	echo "LOAD DATA LOCAL INFILE '$(GENE_PREFIX)/gene2pubmed' INTO TABLE gene2pubmed IGNORE 1 lines (@dummy, gene_id, pmid);" | $(SQL_CMD) > $@.tmp
	mv -f $@.tmp $@


$(GENE_PREFIX)/load_generif.txt:	$(GENE_PARSE)/gene_tables.sql $(GENE_PREFIX)/parsed_basic_rif.txt
	cat $(GENE_PARSE)/gene_tables.sql | $(SQL_CMD)
	echo "DELETE FROM generif" | $(SQL_CMD)
	echo "LOAD DATA LOCAL INFILE '$(GENE_PREFIX)/parsed_basic_rif.txt' INTO TABLE generif IGNORE 1 lines (gene_id, pmid, description);" | $(SQL_CMD) > $@.tmp
	mv -f $@.tmp $@

$(GENE_PREFIX)/all-generif-gene-refs.txt:	\
		$(GENE_PREFIX)/parsed_basic_rif.txt
	cat $(GENE_PREFIX)/parsed_basic_rif.txt | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 1  | uniq | cut -d "|" -f 1 | $(SED_RM_BLANK) | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@

$(GENE_PREFIX)/all-gene2pubmed-gene-refs.txt:	\
		$(GENE_PREFIX)/gene2pubmed
	cat $(GENE_PREFIX)/gene2pubmed | tail -n +2 | sed "y/\t/\|/" | $(BIGSORT) -t "|" -k 2 | uniq | cut -d "|" -f 2 | $(SED_RM_BLANK) | $(UNIQ_COUNT) > $@.tmp
	mv $@.tmp $@

$(GENE_PREFIX)/$(REF_SOURCE)-ref-hist.pdf:
		$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt \
		$(GENE_PARSE)/gene_ref_hist.R
	export PROCESS_INFILE=$(GENE_PREFIX)/all-$(REF_SOURCE)-gene-refs.txt ; export PROCESS_OUTFILE=$@.tmp ; export PROCESS_TITLE=$(REF_SOURCE) References in PubMed; R CMD BATCH --no-save $(GENE_PARSE)/gene_ref_hist.R > $@.log
	mv $@.tmp $@

gene_parse_clean:
	rm -f $(GENE_PREFIX)/gene_info $(GENE_PREFIX)/gene2pubmed 
	rm -f $(GENE_PREFIX)/parsed_basic_rif.txt 
	rm -f $(GENE_PREFIX)/load_gene.txt 
	rm -f $(GENE_PREFIX)/load_gene2pubmed.txt 
	rm -f $(GENE_PREFIX)/load_generif.txt

