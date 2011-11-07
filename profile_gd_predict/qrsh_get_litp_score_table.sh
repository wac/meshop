#!/bin/bash

TXTDIR=../txt/profile_gene_disease

if [ -f $TXTDIR/disease-pharma-chem-litp-profiles.txt ]
then
    echo Found -- $TXTDIR/disease-pharma-chem-litp-profiles.txt
    echo done
    exit
fi

echo Not Found -- $TXTDIR/disease-pharma-chem-litp-profiles.txt


if [ ! -f $TXTDIR/disease-pharma-chem-profiles-score3,4,10.txt ]
then
    cat $TXTDIR/disease-pharma-chem-profiles.txt | grep -E -v "^#" | cut -f 3,4,10 -d "|"  > $TXTDIR/disease-pharma-chem-profiles-score3,4,10.txt.tmp && mv $TXTDIR/disease-pharma-chem-profiles-score3,4,10.txt.tmp $TXTDIR/disease-pharma-chem-profiles-score3,4,10.txt
    exit
fi

ALLOK=Y
for i in {1..100}
do
    for j in {1..100}
    do
	if [ ! -f $TXTDIR/disease-pharma-chem-litp-score_table.$i.$j.txt ]
	then
	    ALLOK=N
	    echo -n "Starting $i $j -- "
	    qsub -l h_vmem=4G get_litp_score_table.sh $i $j
	fi
    done
done

if [ "$ALLOK" == "N" ]
then
    echo "Wait for jobs to terminate then rerun to build final output files"
    exit
fi

if [ ! -f $TXTDIR/disease-pharma-chem-litp-score_table.txt ]
then
    echo All files present -- Generating $TXTDIR/disease-pharma-chem-litp-score_table.txt
    echo Generating $TXTDIR/disease-pharma-chem-litp-score_table.txt
    cat $TXTDIR/disease-pharma-chem-litp-score_table.*.*.txt > $TXTDIR/disease-pharma-chem-litp-score_table.txt.tmp && mv $TXTDIR/disease-pharma-chem-litp-score_table.txt.tmp $TXTDIR/disease-pharma-chem-litp-score_table.txt || exit
    echo done
fi

echo Generating $TXTDIR/disease-pharma-chem-litp-profiles.txt

cat $TXTDIR/disease-pharma-chem-profiles.txt | cut -f 1,2,3,4,10 -d '|' | python merge-litp-score2.py $TXTDIR/disease-pharma-chem-pscores.txt $TXTDIR/disease-pharma-chem-litp-score_table.txt > $TXTDIR/disease-pharma-chem-litp-profiles.txt.tmp && mv $TXTDIR/disease-pharma-chem-litp-profiles.txt.tmp $TXTDIR/disease-pharma-chem-litp-profiles.txt

echo done