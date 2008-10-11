#!/bin/sh
GENEDATE=`date +Gene-%Y-%m-%d`
echo Getting $GENEDATE
mkdir $GENEDATE
cd $GENEDATE
# wget ftp://ftp.ncbi.nih.gov/gene/DATA/ASN_BINARY/All_Data.ags.gz
wget ftp://ftp.ncbi.nih.gov/gene/DATA/gene2go.gz
wget ftp://ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz
wget ftp://ftp.ncbi.nih.gov/gene/DATA/gene2pubmed.gz
wget ftp://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz
# GeneRIFs
wget ftp://ftp.ncbi.nih.gov/gene/GeneRIF/generifs_basic.gz
wget ftp://ftp.ncbi.nih.gov/gene/GeneRIF/hiv_interactions.gz
wget ftp://ftp.ncbi.nih.gov/gene/GeneRIF/interaction_sources
wget ftp://ftp.ncbi.nih.gov/gene/GeneRIF/interactions.gz

cd ..
echo $GENEDATE > newest_version
