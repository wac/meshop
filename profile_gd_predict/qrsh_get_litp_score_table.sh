#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -v PATH
#$ -l h_vmem=60G
#$ -l h_stack=256M
#


TXTDIR=../txt/profile_gene_disease
#SCORE=8
SCORE=12

if [ -f $TXTDIR/disease-pharma-chem-litp-score$SCORE-profiles.txt ]
then
    echo Found -- $TXTDIR/disease-pharma-chem-litp-$SCORE-profiles.txt
    echo done
    exit
fi
echo Not Found -- $TXTDIR/disease-pharma-chem-litp-profiles.txt

if [ ! -f $TXTDIR/disease-pharma-chem-profiles-score3,4,$SCORE.txt ]
then
    echo Not Found -- $TXTDIR/disease-pharma-chem-profiles-score3,4,$SCORE.txt
    cat $TXTDIR/disease-pharma-chem-profiles.txt | grep -E -v "^#" | cut -f 3,4,$SCORE -d "|"  > $TXTDIR/disease-pharma-chem-profiles-score3,4,$SCORE.txt.tmp && mv $TXTDIR/disease-pharma-chem-profiles-score3,4,$SCORE.txt.tmp $TXTDIR/disease-pharma-chem-profiles-score3,4,$SCORE.txt
    echo Generated -- $TXTDIR/disease-pharma-chem-profiles-score3,4,$SCORE.txt
    rm -f $TXTDIR/disease-pharma-chem-litp-score_table.*.*.txt
    echo "Cleared $TXTDIR/disease-pharma-chem-litp-score_table.*.*.txt"
fi

if [ ! -f $TXTDIR/disease-pharma-score$SCORE-chem-pscores.txt ]
then
    echo Running get_lit_pscores.sh $TXTDIR $SCORE
    sh get_lit_pscores.sh $TXTDIR $SCORE
fi

rm -f "$TXTDIR/disease-pharma-chem-profiles-score3,4,X.txt"
ln -s "disease-pharma-chem-profiles-score3,4,$SCORE.txt" "$TXTDIR/disease-pharma-chem-profiles-score3,4,X.txt"

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

if [ ! -f $TXTDIR/disease-pharma-chem-litp-score$SCORE-table.txt ]
then
    echo All files present -- Generating $TXTDIR/disease-pharma-chem-litp-score$SCORE-table.txt
    cat $TXTDIR/disease-pharma-chem-litp-score_table.*.*.txt > $TXTDIR/disease-pharma-chem-litp-score$SCORE-table.txt.tmp && mv $TXTDIR/disease-pharma-chem-litp-score$SCORE-table.txt.tmp $TXTDIR/disease-pharma-chem-litp-score$SCORE-table.txt || exit
    echo done
fi

echo Generating $TXTDIR/disease-pharma-chem-litp-score$SCORE-profiles.txt

cat $TXTDIR/disease-pharma-chem-profiles.txt | cut -f 1,2,3,4,$SCORE -d '|' | python merge-litp-score2.py $TXTDIR/disease-pharma-score$SCORE-chem-pscores.txt $TXTDIR/disease-pharma-chem-litp-score$SCORE-table.txt > $TXTDIR/disease-pharma-chem-litp-score$SCORE-profiles.txt.tmp && mv $TXTDIR/disease-pharma-chem-litp-score$SCORE-profiles.txt.tmp $TXTDIR/disease-pharma-chem-litp-score$SCORE-profiles.txt

echo done