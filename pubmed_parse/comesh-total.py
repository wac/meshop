# Version 3

import sys

def usage():
    print sys.argv[0], " [list of files to process]"
    print ""
    print "Produces a grand total from all the files processed"
    print "Assumes all input files have been sorted using a python string comparison (e.g. sort-comesh.py)"

def merge_min( tuple1, tuple2):
    if not tuple1:
        return tuple2
    
    (f1,key1,val1)=tuple1
    if tuple2:
        (f2, key2,val2)=tuple2
        if key2 < key1:
            return tuple2
        if key2==key1:
            return (f1, key1, val1+val2)
    return tuple1

if len(sys.argv) < 2:
    usage()
    sys.exit(-2)

comesh_tuples = []
sep = '|'

# get the files, initialise the tuples
for i in sys.argv[1:]:
    sys.stderr.write('Open File ' + i + '\n')
    f=open(i, 'r')
    # Init the first tuple
    line=f.readline()
    if line:
        tuple=line.rstrip().split(sep)
        key=tuple[1]+sep+tuple[2] # comesh
        val=int(tuple[0]) # count
        comesh_tuples.append( (f, key, val) )

# Merge
# Terminate when...????
# How to elimnate empty files from the list
# keep a list of empties, delete after the pass
# while comesh_line:
while comesh_tuples:
#    print comesh_tuples
    (f, minkey, val) = reduce (merge_min, comesh_tuples)
    print str(val) + sep + minkey
    emptyfiles = []
    for i in xrange(len(comesh_tuples)):
        # Delete the min and refresh from the file
        (f, key, val) = comesh_tuples[i]
        if key == minkey:
            line = f.readline()
            if not line:
                emptyfiles.insert(0, i)
            else:           
                tuple=line.rstrip().split(sep)
                key=tuple[1]+sep+tuple[2] # comesh
                val=int(tuple[0]) # count
                comesh_tuples[i] =  (f, key, val)               
    for i in emptyfiles:
        del comesh_tuples[i]

    
