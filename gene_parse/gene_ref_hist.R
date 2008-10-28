infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile
title<-Sys.getenv("PROCESS_TITLE")

# Loading into R
gene_refs<-read.table(infile, sep="|", quote="")
gene_refs[1,]
h<-hist(gene_refs[,2], plot=FALSE)
pdf(outfile)
plot(h$counts, log="x", xlab="Gene References", ylab="Frequency", main=title)
dev.off()
