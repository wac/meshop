#! /bin/sh

# Get around query size limitations by only grabbing individual mesh terms and genes

# Get gene_ids and mesh terms (skip header line)
# Since we're looking at gene2pubmed refs,  only get distinct gene ids from there
GENEFILE=hum-gene2pubmed-ids.txt
OUTFILE=hum-gene2pubmed-mesh-parent.txt

#echo "SELECT DISTINCT gene_id FROM gene2pubmed" | mysql-dbrc warrendb | tail -n +2 > all-gene2pubmed-ids.txt
echo "SELECT DISTINCT gene.gene_id FROM gene,gene2pubmed WHERE gene.gene_id=gene2pubmed.gene_id AND gene.taxon_id=9606" | mysql-dbrc warrendb | tail -n +2 > $GENEFILE

printf "#gene_id\tlocus\tterm\tpubmed_refs\n" > $OUTFILE
while read gene_id; do
	echo "Getting $gene_id"
# Use STRAIGHT_JOIN to avoid MySQL optimizer mistakes
	echo "SELECT DISTINCT mesh_parent FROM generif STRAIGHT_JOIN pubmed_mesh_parent WHERE generif.gene_id=$gene_id AND generif.pmid=pubmed_mesh_parent.pmid;" | mysql-dbrc warrendb | tail -n +2 > mesh_parent.tmp
	while read mesh_parent; do
	    echo "Checking $gene_id: $mesh_parent"
	    echo "SELECT gene.gene_id, locus, pubmed_mesh_parent.mesh_parent AS term, COUNT(DISTINCT gene2pubmed.pmid) AS pubmed_refs FROM gene,gene2pubmed, pubmed_mesh_parent WHERE gene.gene_id=$gene_id AND gene2pubmed.pmid=pubmed_mesh_parent.pmid AND gene.gene_id=gene2pubmed.gene_id AND pubmed_mesh_parent.mesh_parent=\"$mesh_parent\" GROUP BY gene_id, mesh_parent;" | mysql-dbrc warrendb | tail -n +2 >> $OUTFILE
	done < mesh_parent.tmp
done < $GENEFILE
