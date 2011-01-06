REF_SOURCE=$1
SQL_CMD=$2

while read geneid
do
  if [ -n "$geneid" ] ; then
      echo "SELECT gene_id, MIN(pubyear) AS oldest_year, COUNT(DISTINCT pubmed.pmid) AS refs FROM  $REF_SOURCE, pubmed WHERE $REF_SOURCE.pmid=pubmed.pmid AND gene_id=$geneid GROUP BY gene_id" | $SQL_CMD | tail -n +2
  fi
done
