infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile
title<-Sys.getenv("PROCESS_TITLE")

# Loading into R
gene_mesh<-read.table(infile, sep="|", quote="")
gene_mesh[1,]
h<-hist(generif_count[,2], plot=FALSE)
plot(h$counts, log="x", xlab="Gene References", ylab="Frequency", main=title)
pdf(outfile)
dev.off()
