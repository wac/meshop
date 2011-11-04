#!/bin/bash

TXTDIR=../txt/profile_gene_disease

for i in {1..100}
do
    for j in {1..100}
    do
	if [ ! -f $TXTDIR/disease-pharma-chem-litp-score_table.$i.$j.txt ]
	then
	    qsub -l h_vmem=4G get_litp_score_table.sh $i $j
	fi
    done
done
