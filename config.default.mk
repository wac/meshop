# Configuration
# Copy this file to config.mk and make changes there 
# Point to your personal directories, etc

# Input Files
# Gzip XML files for PubMed
PUBMED_XML=/home/wcheung/pubmed/baseline-2007
# Gzip XML file for MeSH
MESH_DESC_XML=../../Archive/Mesh/MeSH-2008-01-02/desc2008.gz
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