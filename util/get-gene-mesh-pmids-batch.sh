REF_SOURCE=gene2pubmed
SQL_CMD="mysql-dbrc wcdb3"

while read MESHTERM
do
echo "# $REF_SOURCE $MESHTERM"
while read geneid
do
  if [ -n "$geneid" ] ; then
      echo "SELECT gene.locus,$REF_SOURCE.gene_id, $REF_SOURCE.pmid, pubmed.title FROM $REF_SOURCE, pubmed_mesh_parent, pubmed, gene WHERE gene.gene_id=$REF_SOURCE.gene_id AND pubmed.pmid=$REF_SOURCE.pmid AND $REF_SOURCE.pmid=pubmed_mesh_parent.pmid AND pubmed_mesh_parent.mesh_parent=\"$MESHTERM\" AND $REF_SOURCE.gene_id=$geneid" | $SQL_CMD | tail -n +2
  fi
done < $2
done < $1
echo "# Done"
