import sys

def usage():
    print sys.argv[0], "disease-pharma-chem-pscores.txt disease-pharma-chem-litp-score_table.txt"
    print "stdin: cat disease-pharma-chem-profiles.txt | cut -f 1,2,3,4,10 -d '|'"

if len(sys.argv) <= 2:
    usage()
    exit(1)

sep='|'

disease_p = {}
chem_p = {}

disease_pcut = {}
chem_pcut = {}
score_pcut = {}

f=open(sys.argv[1])
for line in f:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)
    cutval=int(t[0])
    disease_pcut[cutval]=float(t[1])
    chem_pcut[cutval]=float(t[2])
    score_pcut[cutval]=float(t[3])

dcs_p = {}
dcs_count = {}
f=open(sys.argv[2])
for line in f:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)
    dcs_p[(int(t[0]),int(t[1]),int(t[2]))]=float(t[4])
    dcs_count[(int(t[0]),int(t[1]),int(t[2]))]=float(t[3])

print '# disease|chem|score|litp|disease_chem_score_p|score_given_litp'

def minlookup(hash_p, hash_pcuts, name, val):
    p_int=0
    if hash_p and name in hash_p:
        return hash_p[name]
    if val < hash_pcuts[100]:
        for i in xrange(1,101):
            if val < hash_pcuts[i]:
                p_int=i
                break
    else:
        p_int=100
    if hash_p:
        hash_p[name]=p_int
    return p_int
    
for line in sys.stdin:
    if len(line) and line[0]=='#':
        continue
    t=line.strip().split(sep)

    dp=minlookup(disease_p, disease_pcut, t[0], float(t[2]))
    cp=minlookup(chem_p, chem_pcut, t[1], float(t[3]))
    sp=minlookup(False, score_pcut, False, float(t[4]))
    # Need to reverse the p-values, bound from above
    litp= ( (101-dp) * (101-cp) / 10000.0)
    i=dcs_p[(dp,cp,sp)]
    j=dcs_count[(dp,cp,sp)]
    print t[0]+sep+t[1]+sep+t[4]+sep+str(sp)+sep+str(litp)+sep+str(i)+sep+str(j)+sep+str(i/litp)
