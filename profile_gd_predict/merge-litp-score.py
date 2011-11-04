import sys

def usage():
    print sys.argv[0], "disease_term_p.txt chem_term_p.txt disease-pharma-chem-litp-score_table.txt"
    print "stdin: disease_chem_score_p.txt"

if len(sys.argv) <= 3:
    usage()
    exit(1)

sep='|'

disease_p = {}

f=open(sys.argv[1])
for line in f:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)
    disease_p[t[0]]=int(t[2])

chem_p = {}
f=open(sys.argv[2])
for line in f:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)
    chem_p[t[0]]=int(t[2])

dcs_p = {}
f=open(sys.argv[3])
for line in f:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)
    dcs_p[(int(t[0]),int(t[1]),int(t[2]))]=float(t[4])

print '# disease|chem|score|litp|disease_chem_score_p|score_given_litp'

for line in sys.stdin:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)
    dp=disease_p[t[0]]
    cp=chem_p[t[1]]
    sp=int(t[3])
    # Need to reverse the p-values, bound from above
    litp= ( (101-dp) * (101-cp) / 10000.0)
    i=dcs_p[(dp,cp,sp)]
    print t[0]+sep+t[1]+sep+t[2]+sep+str(litp)+sep+str(i)+sep+str(i/litp)
