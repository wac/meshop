# Makefile fragment for mesh_parse/
# Parse the MeSH XML

mesh_parse: $(MESH_PREFIX)/mesh_ids.txt $(MESH_PREFIX)/mesh_tree.txt \
		$(MESH_PREFIX)/mesh-child.txt \
		mesh_parse_db

mesh_parse_db:	$(SQL_PREFIX)/load-mesh-ids.txt \
		$(SQL_PREFIX)/load-mesh-tree.txt

$(MESH_PREFIX)/mesh_ids.txt:	$(MESH_PARSE)/mesh_ids.xsl
	zcat $(MESH_DESC_XML) | xsltproc --novalid $(MESH_PARSE)/mesh_ids.xsl - > $@.tmp
	mv -f $@.tmp $@

$(MESH_PREFIX)/mesh_tree.txt:	$(MESH_PARSE)/mesh_tree.xsl
	zcat $(MESH_DESC_XML) | xsltproc --novalid $(MESH_PARSE)/mesh_tree.xsl - > $@.tmp
	mv -f $@.tmp $@

$(SQL_PREFIX)/load-mesh-ids.txt:	$(MESH_PARSE)/mesh_tables.sql $(MESH_PREFIX)/mesh_ids.txt 
	cat $(MESH_PARSE)/mesh_tables.sql | $(SQL_CMD) 
	echo "DELETE FROM mesh;" | $(SQL_CMD)
	echo "LOAD DATA LOCAL INFILE '$(MESH_PREFIX)/mesh_ids.txt' INTO TABLE mesh FIELDS TERMINATED BY '|' (mesh_ui, term);" | $(SQL_CMD) 
	echo "SELECT COUNT(*) FROM mesh" | $(SQL_CMD) > $@.tmp
	mv -f $@.tmp $@

$(SQL_PREFIX)/load-mesh-tree.txt:	$(MESH_PARSE)/mesh_tables.sql $(MESH_PREFIX)/mesh_tree.txt
	cat $(MESH_PARSE)/mesh_tables.sql | $(SQL_CMD) 
	echo "DELETE FROM mesh_tree;" | $(SQL_CMD)
	echo "LOAD DATA LOCAL INFILE '$(MESH_PREFIX)/mesh_tree.txt' INTO TABLE mesh_tree FIELDS TERMINATED BY '|' (term, tree_num);" | $(SQL_CMD) 
	echo "SELECT COUNT(*) FROM mesh_tree" | $(SQL_CMD) > $@.tmp
	mv -f $@.tmp $@

$(MESH_PREFIX)/mesh-child.txt:	$(SQL_PREFIX)/load-mesh-tree.txt $(MESH_PARSE)/mesh_child.sql
	cat $(MESH_PARSE)/mesh_child.sql | $(SQL_CMD) 
	echo "SELECT * FROM mesh_child" | $(SQL_CMD) | sed "y/\t/\|/" > $@.tmp
	mv -f $@.tmp $@

mesh_parse_clean:
	rm -f $(MESH_PREFIX)/mesh_ids.txt $(MESH_PREFIX)/mesh_tree.txt
	rm -f $(MESH_PREFIX)/mesh-child.txt 
	rm -f $(SQL_PREFIX)/load-mesh-ids.txt 
	rm -f $(SQL_PREFIX)/load-mesh-tree.txt


