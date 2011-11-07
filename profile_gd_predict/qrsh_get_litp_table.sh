#!/bin/bash
# Make sure to run beforehand
# cat disease-pharma-chem-profiles.txt | grep -E -v "^#" | cut -f 3,4,10 -d "|"  > disease-pharma-chem-profiles-score3,4,10.txt

# Run this to generate disease-pharma-chem-litp_table.$1.txt
# $1 == 1 .. 100

TXTDIR=../txt/profile_gene_disease
if [ ! -f $TXTDIR/disease-pharma-chem-profiles-score3,4,10.txt ]
then
    echo "Need to generate the input file - Run:"
    echo -n "cd $TXTDIR ;" 
    echo ' cat disease-pharma-chem-profiles.txt | grep -E -v "^#" | cut -f 3,4,10 -d "|"  > disease-pharma-chem-profiles-score3,4,10.txt.tmp && mv disease-pharma-chem-profiles-score3,4,10.txt.tmp disease-pharma-chem-profiles-score3,4,10.txt'
    exit
fi

# After these are done running, combine to get the final files
for i in {1..100}
do
    if [ ! -f $TXTDIR/disease-pharma-chem-litp_table.$i.txt ]
    then
	echo -n "Starting $i -- "
	qsub -l h_vmem=4G get_litp_table.sh $i
    fi
done
