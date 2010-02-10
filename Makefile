# Requires GNU Make
# Requires presence of xsltproc, pubmed.xsl, pubmed-mesh.xsl

# Global targets
# clean: delete generated files

# ... keep these?  Need to be updated anyways
# setup: make output directories, create the config file if needed
# default:  generate files
# setup-db:  initialise database tables (if needed)
# load-db:  load files into database

EGREP=grep -E -h 
# This file contains the defaults
include config.default.mk
# You can copy the defaults and make changes in config.mk
sinclude config.mk

### Output Directories

TXT_PREFIX=./txt

MESH_PREFIX=$(TXT_PREFIX)/mesh
PUBMED_PREFIX=$(TXT_PREFIX)/pubmed
GENE_PREFIX=$(TXT_PREFIX)/gene
DIRECT_GD_PREFIX=$(TXT_PREFIX)/direct_gene_disease
PROFILE_GD_PREFIX=$(TXT_PREFIX)/profile_gene_disease
SQL_PREFIX=$(TXT_PREFIX)/sql

####### Shared resources
SHARE_PYTHON=./share/python

####### Include subprojects here
default:  mesh_parse gene_parse pubmed_parse direct_gd_predict \
		profile_gd_predict

load_db: gene_parse_db pubmed_parse_db mesh_parse_db

UTIL=./util

MESH_PARSE=./mesh_parse
include $(MESH_PARSE)/mesh_parse.mk

PUBMED_PARSE=./pubmed_parse
include $(PUBMED_PARSE)/pubmed_parse.mk

GENE_PARSE=./gene_parse
include $(GENE_PARSE)/gene_parse.mk

DIRECT_GD_PREDICT=./direct_gd_predict
include $(DIRECT_GD_PREDICT)/direct_gd_predict.mk

PROFILE_GD_PREDICT=./profile_gd_predict
include $(PROFILE_GD_PREDICT)/profile_gd_predict.mk

# Directory for very large temporary files
BIGTMP_DIR=./tmp

# Set TaxonID based on TAXON_NAME
ifeq "$(TAXON_NAME)" "hum"
TAXON_ID=9606
endif

ifeq "$(TAXON_NAME)" "mus"
TAXON_ID=10090
endif

# clean
clean:	mesh_parse_clean gene_parse_clean pubmed_parse_clean
	-rm $(BIGTMP_DIR)/*

