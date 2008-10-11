# Expand GeneRIF text file for database import (v2, python)
# FIXME
# GeneRIFs flat file format: taxid \tab GeneID \tab PMIDs (comma sep) \tab date\tab desc
# Generates a file with format:  GeneID \tab PMID \tab desc

import sys

def usage():
    print sys.argv[0], " [list of files to process]"
    print sys.argv[0], "  Expand GeneRIF files (use '-' for stdin)"


if len(sys.argv) < 2:
    usage()
    sys.exit(-2)

comesh_total = []
sep = '\t'
sep2 = ','

print "# gene_id\tpmid\tdescription"

for i in sys.argv[1:]:
    sys.stderr.write('Processing File ' + i + '\n')
    if i=='-' :
        f=sys.stdin
    else:
        f=open(i, 'r')
        
    for line in f:
        if line[0]=='#': # skip comments
            continue
        tuple=line.split(sep)
        gene_id=tuple[1]
        pmid_list=tuple[2].split(sep2)
        for pmid in pmid_list:
            print gene_id+'\t'+pmid+'\t'+tuple[4]
    f.close()


