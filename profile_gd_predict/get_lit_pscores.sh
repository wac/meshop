#!/bin/bash

TXTDIR=$1
SCORE=$2

echo Checking for $TXTDIR/disease-pharma-score$SCORE-chem-pscores.txt

if [ ! -f $TXTDIR/disease-pharma-score$SCORE-chem-pscores.txt ]
then
    echo "Generating $TXTDIR/disease-pharma-score$SCORE-chem-pscores.txt"
    echo "dpc<-read.table('disease-pharma-chem-profiles-score3,4,$SCORE.txt', sep='|', header=FALSE, quote='', comment.char='')" > $TXTDIR/disease-pharma-score$SCORE-chem-pscores.R
    echo "dpc.pscore3<-quantile(dpc[,1], seq(0,0.99, 0.01))" >> $TXTDIR/disease-pharma-score$SCORE-chem-pscores.R
    echo "dpc.pscore4<-quantile(dpc[,2], seq(0,0.99, 0.01))
dpc.pscore10<-quantile(dpc[,3], seq(0,0.99, 0.01))" >> $TXTDIR/disease-pharma-score$SCORE-chem-pscores.R
    echo "dpc.pscores<-cbind(1:100, dpc.pscore3, dpc.pscore4, dpc.pscore10)" >> $TXTDIR/disease-pharma-score$SCORE-chem-pscores.R
    echo "write.table(dpc.pscores, 'disease-pharma-score$SCORE-chem-pscores.txt', sep='|', row.names=FALSE, col.names=FALSE, quote=FALSE)" >> $TXTDIR/disease-pharma-score$SCORE-chem-pscores.R
    cd $TXTDIR ; R CMD BATCH --vanilla disease-pharma-score$SCORE-chem-pscores.R
fi

