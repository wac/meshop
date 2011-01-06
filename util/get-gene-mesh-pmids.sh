# Set REF_SOURCE to gene2pubmed or generif
# pass in as first parameter mesh term 
# pass in via stdin geneIDs to test, one per line

REF_SOURCE=gene2pubmed
SQL_CMD="mysql-dbrc wcdb3"
MESHTERM=$1

echo "# $REF_SOURCE $1"

while read geneid
do
  if [ -n "$geneid" ] ; then
      echo "SELECT gene.locus,$REF_SOURCE.gene_id, $REF_SOURCE.pmid, pubmed.title FROM $REF_SOURCE, pubmed_mesh_parent, pubmed, gene WHERE gene.gene_id=$REF_SOURCE.gene_id AND pubmed.pmid=$REF_SOURCE.pmid AND $REF_SOURCE.pmid=pubmed_mesh_parent.pmid AND pubmed_mesh_parent.mesh_parent=\"$MESHTERM\" AND $REF_SOURCE.gene_id=$geneid" | $SQL_CMD | tail -n +2
  fi
done
