# setup: make output directories
# default:  generate files
# setup-db:  initialise database tables (if needed)
# load-db:  load files into database

# This Makefile takes the Pubmed XML files and creates tables:
# pubmed_mesh:  the mesh terms for each PMID
# pubmed_mesh_parent:  same as pumbed_mesh, but expanded with parent terms

# It also computes co-occurring mesh terms and places it into the file
# comesh-total.txt

# Output Directories
PM_MESH_PREFIX=$(PUBMED_PREFIX)/mesh
PM_MESH_PARENT_PREFIX=$(PUBMED_PREFIX)/mesh_parent
PM_TITLES_PREFIX=$(PUBMED_PREFIX)/titles
PM_COMESH_PREFIX=$(PUBMED_PREFIX)/comesh
PM_CHEM_PREFIX=$(PUBMED_PREFIX)/chem
PM_AUTHOR_PREFIX=$(PUBMED_PREFIX)/author

PUBMED_XML_GZ=$(wildcard $(PUBMED_XML)/*.xml.gz)

PUBMED_TITLES_TXT=$(PUBMED_XML_GZ:$(PUBMED_XML)/%.xml.gz=$(PM_TITLES_PREFIX)/%.titles.txt)
PUBMED_MESH_TXT=$(PUBMED_XML_GZ:$(PUBMED_XML)/%.xml.gz=$(PM_MESH_PREFIX)/%.mesh.txt)
PUBMED_MESH_PARENT_TXT=$(PUBMED_XML_GZ:$(PUBMED_XML)/%.xml.gz=$(PM_MESH_PARENT_PREFIX)/%.mesh-parent.txt)
PUBMED_COMESH_TXT=$(PUBMED_XML_GZ:$(PUBMED_XML)/%.xml.gz=$(PM_COMESH_PREFIX)/%.comesh.txt) 
PUBMED_CHEM_TXT=$(PUBMED_XML_GZ:$(PUBMED_XML)/%.xml.gz=$(PM_CHEM_PREFIX)/%.chem.txt)
PUBMED_AUTHOR_TXT=$(PUBMED_XML_GZ:$(PUBMED_XML)/%.xml.gz=$(PM_AUTHOR_PREFIX)/%.author.txt)

# XSL conversion files
# PMIDs and Article Titles
PUBMED_TITLES_XSL=$(PUBMED_PARSE)/pubmed-baseline-titles.xsl
# PMIDs, MeSH Terms, Major Topic, Qualifier, Major Topic
PUBMED_MESH_XSL=$(PUBMED_PARSE)/pubmed-baseline-mesh.xsl
# PMIDs, Chemical Name
PUBMED_CHEM_XSL=$(PUBMED_PARSE)/pubmed-baseline-chem.xsl
# PMIDs, Authors
PUBMED_AUTHOR_XSL=$(PUBMED_PARSE)/pubmed-baseline-author.xsl
# MeSH Child imported from mesh_parse
MESH_CHILD=$(MESH_PREFIX)/mesh-child.txt

# XSLT processor
# Gnome libxslt processor
XSLT_PUBMED_TITLES_CMD=xsltproc --novalid $(PUBMED_TITLES_XSL) -
XSLT_PUBMED_MESH_CMD=xsltproc --novalid $(PUBMED_MESH_XSL) -
XSLT_PUBMED_CHEM_CMD=xsltproc --novalid $(PUBMED_CHEM_XSL) -
XSLT_PUBMED_AUTHOR_CMD=xsltproc --novalid $(PUBMED_AUTHOR_XSL) -

pubmed_parse: $(PUBMED_TITLES_TXT) $(PUBMED_MESH_TXT) $(PUBMED_CHEM_TXT) \
	$(PUBMED_MESH_PARENT_TXT) $(PUBMED_COMESH_TXT) \
	$(PM_COMESH_PREFIX)/comesh-total.txt \
	$(PM_TITLES_PREFIX)/load-titles.txt $(PM_CHEM_PREFIX)/load-chem.txt \
	$(PM_MESH_PREFIX)/load-mesh.txt \
	$(PM_MESH_PARENT_PREFIX)/load-mesh-parent.txt

pubmed_parse_titles:	$(PUBMED_TITLES_TXT)
pubmed_parse_mesh:	$(PUBMED_MESH_TXT)
pubmed_parse_chem:	$(PUBMED_CHEM_TXT)
pubmed_parse_author:	$(PUBMED_AUTHOR_TXT)

pubmed_parse_clean:
	rm -f $(PM_TITLES_PREFIX)/*.titles.txt
	rm -f $(PM_MESH_PREFIX)/*.mesh.txt
	rm -f $(PM_CHEM_PREFIX)/*.chem.txt
	rm -f $(PM_MESH_PARENT_PREFIX)/*.mesh-parent.txt
	rm -f $(PM_COMESH_PREFIX)/*.comesh.txt

$(PM_TITLES_PREFIX)/%.titles.txt: $(PUBMED_XML)/%.xml.gz \
		$(PUBMED_PARSE)/pubmed-baseline-titles.xsl
	zcat $< | $(XSLT_PUBMED_TITLES_CMD) >> $@.tmp 
	mv $@.tmp $@

$(PM_MESH_PREFIX)/%.mesh.txt: $(PUBMED_XML)/%.xml.gz \
		$(PUBMED_PARSE)/pubmed-baseline-mesh.xsl
	zcat $< | $(XSLT_PUBMED_MESH_CMD) >> $@.tmp 
	mv $@.tmp $@


$(PM_CHEM_PREFIX)/%.chem.txt: $(PUBMED_XML)/%.xml.gz \
		$(PUBMED_PARSE)/pubmed-baseline-chem.xsl
	zcat $< | $(XSLT_PUBMED_CHEM_CMD) >> $@.tmp 
	mv $@.tmp $@

$(PM_AUTHOR_PREFIX)/%.author.txt: $(PUBMED_XML)/%.xml.gz \
		$(PUBMED_PARSE)/pubmed-baseline-author.xsl \
		$(PUBMED_PARSE)/pubmed-baseline-author.py 
	zcat $< | $(XSLT_PUBMED_AUTHOR_CMD) | python $(PUBMED_PARSE)/pubmed-baseline-author.py >> $@.tmp 
	mv $@.tmp $@

$(PM_MESH_PARENT_PREFIX)/%.mesh-parent.txt $(PM_COMESH_PREFIX)/%.comesh.txt: $(PM_MESH_PREFIX)/%.mesh.txt $(MESH_CHILD)
	python $(PUBMED_PARSE)/pubmed-mesh-parent-join.py $(MESH_CHILD) $< $(PM_MESH_PARENT_PREFIX)/$*.mesh-parent.txt.tmp $(PM_COMESH_PREFIX)/$*.comesh.txt.tmp 
	mv $(PM_MESH_PARENT_PREFIX)/$*.mesh-parent.txt.tmp $(PM_MESH_PARENT_PREFIX)/$*.mesh-parent.txt 
	cat $(PM_COMESH_PREFIX)/$*.comesh.txt.tmp | python $(PUBMED_PARSE)/sort-comesh.py - > $(PM_COMESH_PREFIX)/$*.comesh.txt.sort.tmp
	rm $(PM_COMESH_PREFIX)/$*.comesh.txt.tmp
	mv $(PM_COMESH_PREFIX)/$*.comesh.txt.sort.tmp $(PM_COMESH_PREFIX)/$*.comesh.txt

$(PM_COMESH_PREFIX)/comesh-total.txt: $(PUBMED_COMESH_TXT)
	python $(PUBMED_PARSE)/comesh-total.py  $(PUBMED_COMESH_TXT) > $(PM_COMESH_PREFIX)/comesh-total.txt.tmp
	mv  $(PM_COMESH_PREFIX)/comesh-total.txt.tmp $(PM_COMESH_PREFIX)/comesh-total.txt

$(PM_TITLES_PREFIX)/load-titles.txt: $(PUBMED_TITLES_TXT)
	cat $(PUBMED_PARSE)/pubmed_tables.sql | $(SQL_CMD)
	echo "DELETE FROM pubmed" | $(SQL_CMD)
	for file in $(PUBMED_TITLES_TXT); do echo "LOAD DATA LOCAL INFILE '$$file' INTO TABLE pubmed FIELDS TERMINATED by '|' IGNORE 1 LINES" | $(SQL_CMD); done
	echo "SELECT COUNT(*) FROM pubmed;" | $(SQL_CMD) | tail -n +2 > $@

$(PM_CHEM_PREFIX)/load-chem.txt: $(PUBMED_CHEM_TXT)
	cat $(PUBMED_PARSE)/pubmed_tables.sql | $(SQL_CMD)
	echo "DELETE FROM pubmed_chem" | $(SQL_CMD)
	for file in $(PUBMED_CHEM_TXT) ; do echo "LOAD DATA LOCAL INFILE '$$file' INTO TABLE pubmed_chem FIELDS TERMINATED by '|' IGNORE 1 LINES" | $(SQL_CMD) ; done
	echo "SELECT COUNT(*) FROM pubmed_chem" | $(SQL_CMD) | tail -n +2  > $@.tmp
	mv $@.tmp $@

$(PM_MESH_PREFIX)/load-mesh.txt: $(PUBMED_MESH_TXT)
	cat $(PUBMED_PARSE)/pubmed_tables.sql | $(SQL_CMD)
	echo "DELETE FROM pubmed_mesh" | mysql-dbrc $DBNAME
	for file in $(PUBMED_MESH_TXT); do echo "LOAD DATA LOCAL INFILE '$$file' INTO TABLE pubmed_mesh FIELDS TERMINATED by '|' IGNORE 1 LINES" | $(SQL_CMD) ; done
	echo "SELECT COUNT(*) FROM pubmed_mesh" | $(SQL_CMD) | tail -n +2  > $@.tmp
	mv $@.tmp $@

$(PM_MESH_PARENT_PREFIX)/load-mesh-parent.txt: $(PUBMED_MESH_PARENT_TXT)
	cat $(PUBMED_PARSE)/pubmed_tables.sql | $(SQL_CMD)
	echo "DELETE FROM pubmed_mesh_parent" | mysql-dbrc $DBNAME
	for file in $(PUBMED_MESH_PARENT_TXT); do echo "LOAD DATA LOCAL INFILE '$$file' INTO TABLE pubmed_mesh_parent FIELDS TERMINATED by '|' IGNORE 1 LINES" | $(SQL_CMD); done > $@.tmp
	mv $@.tmp $@

$(PM_AUTHOR_PREFIX)/load-author.txt: $(PUBMED_AUTHOR_TXT)
	cat $(PUBMED_PARSE)/pubmed_tables.sql | $(SQL_CMD)
	echo "DELETE FROM pubmed_author" | mysql-dbrc $DBNAME
	for file in $(PUBMED_AUTHOR_TXT); do echo "LOAD DATA LOCAL INFILE '$$file' INTO TABLE pubmed_author FIELDS TERMINATED by '|' IGNORE 1 LINES" | $(SQL_CMD); done > $@.tmp
	mv $@.tmp $@
