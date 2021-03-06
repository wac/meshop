# Don't Run this directly - need to supply $1 == cut level
TXTDIR=../txt/profile_gene_disease
SCRIPTFILE=get_litp_table.$1.R

echo "dpc<-read.table('disease-pharma-chem-profiles-score3,4,10.txt', sep='|', header=FALSE, quote='', comment.char='')" > $TXTDIR/$SCRIPTFILE
echo "dpc.pscore3<-quantile(dpc[,1], seq(0,0.99, 0.01))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.pscore4<-quantile(dpc[,2], seq(0,0.99, 0.01))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.pscore10<-quantile(dpc[,3], seq(0,0.99, 0.01))" >> $TXTDIR/$SCRIPTFILE

echo "dpc.pscores<-cbind(dpc.pscore3, dpc.pscore4, dpc.pscore10)" >> $TXTDIR/$SCRIPTFILE

echo "probs<-cbind($1,seq(1:100))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.lit_p<-cbind(probs, apply(probs, 1, function(x) sum(dpc[,1] > dpc.pscore3[x[1]] & dpc[,2] > dpc.pscore4[x[2]])))" >> $TXTDIR/$SCRIPTFILE
echo "dpc.lit_p<-cbind(dpc.lit_p, dpc.lit_p[,3]/dim(dpc)[1])" >> $TXTDIR/$SCRIPTFILE
echo "write.table(dpc.lit_p, 'disease-pharma-chem-litp_table.$1.txt', sep='|', row.names=FALSE, col.names=FALSE, quote=FALSE)" >> $TXTDIR/$SCRIPTFILE

cd $TXTDIR ; R CMD BATCH --vanilla $SCRIPTFILE
