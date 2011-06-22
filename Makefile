# Requires GNU Make
# Requires presence of xsltproc, pubmed.xsl, pubmed-mesh.xsl

# if TAXON_NAME is not defined to a species (sets TAXON_ID), you
# will need to provide txt/direct_gene_disease/$(TAXON_NAME)-gene.txt

# Global targets
# clean: delete generated files

# ... keep these?  Need to be updated anyways
# setup: make output directories, create the config file if needed
# default:  generate files except for predictions
# all: also generate profile predictions

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
.PHONY: default mesh_parse gene_parse pubmed_parse direct_gd_predict \
		profile_gd_predict \
		load_db gene_parse_db pubmed_parse_db \
		mesh_parse_db \
		clean mesh_parse_clean gene_parse_clean pubmed_parse_clean \
		cleanup

default:  mesh_parse gene_parse pubmed_parse direct_gd_predict 

all: default profile_gd_predict

load_db: gene_parse_db pubmed_parse_db mesh_parse_db

# Directory for very large temporary files
BIGTMP_DIR=./tmp

# Set TaxonID based on TAXON_NAME
ifeq "$(TAXON_NAME)" "hum"
TAXON_ID=9606
endif

ifeq "$(TAXON_NAME)" "mus"
TAXON_ID=10090
endif

ifeq "$(TAXON_NAME)" "sce"
TAXON_ID=4932
endif

# Include sub-Makefiles

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

# clean
clean:	mesh_parse_clean gene_parse_clean pubmed_parse_clean cleanup
	cat sql/drop-tables.sql | $(SQL_CMD)
	-rm $(SQL_PREFIX)/*.txt

# delete temporary files
cleanup:
	-rm $(BIGTMP_DIR)/*
	-$(MAKE) -f $(DIRECT_GD_PREFIX)/all-comesh-p.txt.mk cleanup
	-$(MAKE) -f $(DIRECT_GD_PREFIX)/all-$(REF_SOURCE)-gene-mesh-p.txt.mk cleanup
	-$(MAKE) -f $(DIRECT_GD_PREFIX)/diseaseBG-disease-comesh-p.txt.mk cleanup
	-$(MAKE) -f $(DIRECT_GD_PREFIX)/$(REF_SOURCE)BG-$(TAXON_NAME)-$(REF_SOURCE)-gene-mesh-p.txt.mk cleanup
	-$(MAKE) -f $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt.mk cleanup
	-$(MAKE) -f $(PROFILE_GD_PREFIX)/BG-$(TAXON_NAME)-gene-gene-$(REF_SOURCE)-profiles.txt.mk cleanup
	-$(MAKE) -f $(PROFILE_GD_PREFIX)/disease-disease-profiles.txt.mk cleanup
	-$(MAKE) -f $(PROFILE_GD_PREFIX)/$(TAXON_NAME)-disease-$(REF_SOURCE)-profiles.txt.mk cleanup



