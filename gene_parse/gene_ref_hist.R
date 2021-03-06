infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile
title<-Sys.getenv("PROCESS_TITLE")

# Loading into R
gene_refs<-read.table(infile, sep="|", quote="")
gene_refs[1,]
h<-hist(gene_refs[,2], plot=FALSE, breaks=max(gene_refs[,2]))
pdf(outfile)
plot(h, col="blue", main=title, xlab="Number of References", ylab="Frequency", right=FALSE)
plot(h, col="blue", xlim=c(0,20), ylim=c(0,5000), main=title, xlab="Number of References", ylab="Frequency", right=FALSE)
dev.off()
