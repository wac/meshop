# Configuration
# Copy this file to config.mk and make changes there 
# Point to your personal directories, etc

# Input Files
# Gzip XML files for PubMed
PUBMED_XML=/home/wcheung/pubmed/baseline-2007
# Gzip XML file for MeSH & Supplementals
MESH_DESC_XML=/home/wcheung/MeSH/MeSH-2007/desc2007.gz
MESH_SUPP_DESC_XML=/home/wcheung/MeSH/MeSH-2007/supp2007.gz
# Directory for EntrezGene snapshot
# contains DATA/gene2pubmed.gz, DATA/gene_info.gz, GeneRIF/generifs_basic.gz
GENE_DIR=../../Archive/EntrezGene/Gene-2007-02-13

# Database Access
# DB Name
DB_NAME=warrendb
# SQL commands will be piped via standard input to this command
SQL_CMD=mysql-dbrc $(DB_NAME)

REF_SOURCE=gene2pubmed

TAXON_NAME=hum

# Commands

# Count unique lines using uniq -c
# output pipe-delimited format =>  line|count
UNIQ_COUNT=uniq -c | sed -r 's/^[[:blank:]]*([[:digit:]]*)[[:blank:]]*(.*)/\2\|\1/'

# Command to remove blank lines from output
SED_RM_BLANK=sed '/^$$/d'
