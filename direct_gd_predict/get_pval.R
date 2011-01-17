infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile

# Loading into R
gene_mesh<-read.table(infile, sep="|", quote="", comment.char="")
gene_mesh[1,]

# Computing p-values
# Compute P[x <= X],  where x is number of articles without the annotation
# is less than or equal to X

# Can also compute as
#gene_mesh.p<-phyper(gene_mesh[,3], gene_mesh[,5], gene_mesh[,6], gene_mesh[,4], lower.tail=FALSE) + dhyper(gene <- mesh[,3], gene <- mesh[,5], gene <- mesh[,6], gene <- mesh[,4])
gene_mesh.p<-phyper((gene_mesh[,4] - gene_mesh[,3]), gene_mesh[,6], gene_mesh[,5], gene_mesh[,4])

gene_mesh.tfidf<- (gene_mesh[,3]/gene_mesh[,4])*(log( (gene_mesh[,5]+gene_mesh[,6])/gene_mesh[,5]))

# Add the column
gene_mesh_all <- cbind(gene_mesh, gene_mesh.p, gene_mesh.tfidf)

# Write output
write.table(gene_mesh_all, outfile, sep="|", row.names=FALSE, col.names=FALSE, quote=FALSE)

