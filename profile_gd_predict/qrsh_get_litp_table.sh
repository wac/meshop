#!/bin/bash
for i in {1..100}
do
    qsub -l h_vmem=4G get_litp_table.sh $i
done
