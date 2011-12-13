TXTDIR=../txt/profile_gene_disease
SCRIPTFILE=get_litp_score_table.$1.$2.R

#Implemented binning (rather than more extremal, get local dist)
D=5

echo "dpc<-read.table('disease-pharma-chem-profiles-score3,4,X.txt', sep='|', header=FALSE, quote='', comment.char='')" > $TXTDIR/$SCRIPTFILE
echo "dpc.pscore3<-quantile(dpc[,1], seq(0,0.99, 0.01))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.pscore4<-quantile(dpc[,2], seq(0,0.99, 0.01))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.pscoreX<-quantile(dpc[,3], seq(0,0.99, 0.01))" >> $TXTDIR/$SCRIPTFILE

echo "dpc.pscores<-cbind(dpc.pscore3, dpc.pscore4, dpc.pscoreX)" >> $TXTDIR/$SCRIPTFILE

echo "probs<-cbind($1,$2,seq(1:100))" >> $TXTDIR/$SCRIPTFILE
echo "probs.i<- min(max($1-$D, 1), 100-$D-$D+1)" >> $TXTDIR/$SCRIPTFILE
echo "probs.j<-min(max($2-$D, 1), 100-$D-$D+1)" >> $TXTDIR/$SCRIPTFILE
echo "probs.test<-cbind( probs.i, probs.j, seq(1:100))" >> $TXTDIR/$SCRIPTFILE
echo "probs.test" >> $TXTDIR/$SCRIPTFILE
echo "probs.scores<- sum(dpc[,1] > dpc.pscore3[probs.i] & dpc[,1] < dpc.pscore3[probs.i+$D+$D-1]& dpc[,2] > dpc.pscore4[probs.j] & dpc[,2] < dpc.pscore4[probs.j+$D+$D-1])" >> $TXTDIR/$SCRIPTFILE
echo "probs.scores" >> $TXTDIR/$SCRIPTFILE
# Note that we want more extreme results
# so more terms than the drug, more terms than the disease
# but "better" score than the score (THIS NEEDS TO MATCH THE SCORE DIRECTION)
# You will need to use '<' if the raw AUC > 0.5 and '>' if raw AUC < 0.5
#echo "dpc.lit_p<-cbind(probs, apply(probs, 1, function(x) sum(dpc[,1] > dpc.pscore3[x[1]] & dpc[,2] > dpc.pscore4[x[2]] & dpc[,3] < dpc.pscoreX[x[3]])))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.lit_p<-cbind(probs, apply(probs.test, 1, function(x) sum(dpc[,1] > dpc.pscore3[x[1]] & dpc[,1] < dpc.pscore3[x[1]+$D+$D-1]& dpc[,2] > dpc.pscore4[x[2]] & dpc[,2] < dpc.pscore4[x[2]+$D+$D-1] & dpc[,3] > dpc.pscoreX[x[3]])))" >> $TXTDIR/$SCRIPTFILE
#echo "dpc.lit_p<-cbind(dpc.lit_p, dpc.lit_p[,4]/dim(dpc)[1])" >> $TXTDIR/$SCRIPTFILE
echo "dpc.lit_p<-cbind(dpc.lit_p, dpc.lit_p[,4]/probs.scores)" >> $TXTDIR/$SCRIPTFILE
echo "write.table(dpc.lit_p, 'disease-pharma-chem-litp-score_table.$1.$2.txt', sep='|', row.names=FALSE, col.names=FALSE, quote=FALSE)" >> $TXTDIR/$SCRIPTFILE

cd $TXTDIR ; R CMD BATCH --vanilla $SCRIPTFILE
