import sys

split_num=500
#split_num=100
#split_num=40

def usage():
    print sys.argv[0], " <gene-profiles> <output prefix>"
    print "Splits the gene profiles in <gene-profiles> into sets of "+str(split_num)
    print "Ouputs files <output prefix>-1.txt, <output prefix>-2.txt and so on"
    

if len(sys.argv) <= 2:
	usage()
	exit(-1)


sep='|'

prefix=sys.argv[2]
currgene=0
numgenes=0
numfile=1
outfilename=prefix+str(numfile)+'.txt'
outfile=open(outfilename, 'w')

gfile=open(sys.argv[1], 'r')
for line in gfile:
    if line[0] == '#':
        continue

    outfile.write(line)

    tuple=line.strip().split(sep)
    gene=tuple[0]

    if not(currgene):
        currgene=gene

    if not(gene==currgene):
        currgene=gene
        numgenes=numgenes+1
        if numgenes < split_num:
            continue
        numgenes = 0
        outfile.close()
        numfile=numfile+1
        outfilename=prefix+str(numfile)+'.txt'
        outfile=open(outfilename, 'w')

