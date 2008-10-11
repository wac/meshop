infile<-Sys.getenv("PROCESS_INFILE")
infile
outfile<-Sys.getenv("PROCESS_OUTFILE")
outfile

# Loading into R
gene_mesh<-read.table(infile, sep="|", quote="")
gene_mesh[1,]

# Computing p-values
gene_mesh.p<-phyper(gene_mesh[,3], gene_mesh[,5], gene_mesh[,6], gene_mesh[,4], lower.tail=FALSE)

# Add the column
gene_mesh_all <- cbind(gene_mesh, gene_mesh.p)

# Write output
write.table(gene_mesh_all, outfile, sep="|", row.names=FALSE, col.names=FALSE, quote=FALSE)

