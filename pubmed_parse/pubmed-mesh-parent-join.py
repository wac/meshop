import sys
from sets import Set

def usage():
    print sys.argv[0], " mesh_child_file pubmed_mesh file [mesh_parent output] [mesh_counts]"
    print sys.argv[0], " [mesh_parent output] and [mesh_counts] are optional (mesh_parent defaults to stdout, mesh_counts will be skipped)"

if len(sys.argv) < 3:
    usage()
    sys.exit(-2)

mesh_child_file=sys.argv[1]
pubmed_file=sys.argv[2]
sep='|'

#co-occurring MeSH terms
coMeSH = {}

mesh_parent = {}

if len(sys.argv) < 4:
    f2=sys.stdout
else:
    f2=open(sys.argv[3], 'w')
    if len(sys.argv) < 5:
        f3=sys.stdout
        coMeSH=False
    else:
        f3=open(sys.argv[4], 'w')

f=open(mesh_child_file)
for line in f:
    tuple=line.rstrip().split(sep)
    key=tuple[1] # child
    val=tuple[0] # parent
    if key in mesh_parent:
        mesh_parent[key].add(val)
    else:
        mesh_parent[key] = Set([ val ])

#for key in mesh_parent:
#    print key, "|", mesh_parent[key]

f=open(pubmed_file, 'r')
parents = Set([])
curr_pmid="-1"


for line in f:
    tuple=line.rstrip().split(sep)
    pmid=tuple[0]
    mesh_id=tuple[1]
#    print "pmid=", pmid, "meshid", mesh_id
    if pmid != curr_pmid:
        if pmid != -1:
            for parent_id in parents:
                f2.write(curr_pmid + "|" + parent_id + "\n")
                for parent_id2 in parents:
                    key = parent_id + "|" + parent_id2
                    if coMeSH:
                        if key in coMeSH:
                            coMeSH[key]=coMeSH[key]+1
                        else:
                            coMeSH[key]=1
        curr_pmid=pmid
        parents = Set([])
    if mesh_id in mesh_parent:
        parents=parents.union(mesh_parent[mesh_id])
#    print "mesh_parent", mesh_parent[mesh_id]
#    print "Parents", parents

if coMeSH:
    for key in coMeSH:
        f3.write(str(coMeSH[key]) + "|" + key + "\n")

