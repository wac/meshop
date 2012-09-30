import sys
import random
import heapq

# Find # occurrences and average p-value for MeSH terms

# Count
h={}
# Sum
s={}

# counts at various cuts
cut05 ={}
cut005 ={}
cut01 ={}
cut001 ={}

# Total authors
n=0
last_auth=''

sep='|'

for line in sys.stdin:
    tuples=line.strip().split(sep)
    if tuples[0] != last_auth:
        last_auth=tuples[0]
        n=n+1
    if tuples[1] in h:
        h[tuples[1]] += 1
        p = float(tuples[6])
        s[tuples[1]] += p
        if p < 0.5:
            cut05[tuples[1]] += 1
            if p < 0.1:
                cut01[tuples[1]] += 1
                if p < 0.05:
                    cut005[tuples[1]] += 1
                    if p < 0.01:
                        cut001[tuples[1]] += 1
    else:
        h[tuples[1]] = 1

        cut05[tuples[1]] = 0
        cut005[tuples[1]] = 0
        cut01[tuples[1]] = 0
        cut001[tuples[1]] = 0
        
        p = float(tuples[6])
        s[tuples[1]] = p
        if p < 0.5:
            cut05[tuples[1]] += 1
            if p < 0.1:
                cut01[tuples[1]] += 1
                if p < 0.05:
                    cut005[tuples[1]] += 1
                    if p < 0.01:
                        cut001[tuples[1]] += 1
print "# processed", n, "authors"
for (a,b) in h.iteritems():
    print a+sep+str(b)+sep+str(s[a])+sep+str(s[a]/b)+sep+str((s[a]+n-b)/n)+sep+str(cut05[a])+sep+str(cut01[a])+sep+str(cut005[a])+sep+str(cut001[a])


