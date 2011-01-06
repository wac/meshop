import string
import sys

score_col=11

def usage():
    print sys.argv[0], " <profile prediction file>"
    print "Convert input prediction file into graph in lgl format"
    print "Edge weights are taken from column", (score_col+1)
    print "Print result to stdout"

def getGeneHash(word,ghash, gset):
    if word in ghash:
        return ghash[word]
    new_hash=''.join(c for c in word if c in string.ascii_letters)
    i=0
    while (new_hash+str(i)) in gset:
        i=i+1
    new_hash=new_hash+str(i)
    gset.add(new_hash)
    ghash[word]=new_hash
    return new_hash

if len(sys.argv) <= 1:
	usage()
	exit(-1)

sep='|'

currgene=0
genehash = { }
genehashset = set()
edgeset = set()

gfile=open(sys.argv[1], 'r')
for line in gfile:
    if line[0] == '#':
        continue

    tuple=line.strip().split(sep)
    gene=getGeneHash(tuple[0], genehash, genehashset)
    gene2=getGeneHash(tuple[1], genehash, genehashset)
    score=tuple[score_col]

    if not(currgene) or not(gene==currgene):
        currgene=gene
        print "#", currgene

    if ((gene,gene2) in edgeset) or ((gene2,gene) in edgeset):
        # Edge already done
        continue
    print gene2, score
    edgeset.add( (gene,gene2) )
