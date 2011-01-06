# Set REF_SOURCE to gene2pubmed or generif
# pass in as first parameter mesh term 
# pass in via stdin geneIDs to test, one per line

REF_SOURCE=gene2pubmed
SQL_CMD="mysql-dbrc wcdb4"
TAXONID=9606

echo "# $REF_SOURCE"

while read geneid
do
  if [ -n "$geneid" ] ; then
      echo "SELECT gene.locus,$REF_SOURCE.gene_id, COUNT(DISTINCT $REF_SOURCE.pmid) FROM $REF_SOURCE, gene WHERE gene.gene_id=$REF_SOURCE.gene_id AND $REF_SOURCE.gene_id='$geneid' GROUP BY $REF_SOURCE.gene_id" | $SQL_CMD | tail -n +2
  fi
done
