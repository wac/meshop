# Sort a file
# Need to do this since I'm getting different sort results from the
# system sort

import sys

def usage():
    print sys.argv[0], " [list of files to process]"
    print sys.argv[0], " sort the lines from the input files (use '-' for stdin)"


if len(sys.argv) < 2:
    usage()
    sys.exit(-2)

comesh_total = []
sep = '|'

for i in sys.argv[1:]:
    sys.stderr.write('Processing File ' + i + '\n')
    if i=='-' :
        f=sys.stdin
    else:
        f=open(i, 'r')
        
    for line in f:
        tuple=line.rstrip().split(sep)
        key=tuple[1]+sep+tuple[2] # comesh
        val=int(tuple[0]) # count
        comesh_total.append( (key, val) )
    f.close()
sys.stderr.write('Sorting ' + i + '\n')
comesh_total.sort()
# print comesh_total
for (key, val) in comesh_total:
    print str(val)+sep+key
