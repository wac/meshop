import sys
import heapq

# Splits each lines based on sep
# ignores and prints lines starting with '#'
# Keeps the top 'heapsize' lines,  based on 'val_col', for each set for 'key_col'

sep='|'
key_col=0
val_col=1
heapsize=50

old_key=False

h=[]

if (len(sys.argv) > 1):
    heapsize=int(sys.argv[1])

if (len(sys.argv) > 2):
    key_col=int(sys.argv[2])

if (len(sys.argv) > 3):
    val_col=int(sys.argv[3])


for line in sys.stdin:
    line=line.strip()
    if line[0]=='#':
        print line
        continue
    tuples=line.split(sep)

    curr_key=tuples[key_col]

    if not old_key:
        old_key=curr_key
    
    if not old_key==curr_key:
        for (a,b) in h:
            print b
        h=[]

        old_key=curr_key

    item=(-float(tuples[val_col]),line)

    if (len(h) < heapsize):
        heapq.heappush(h, item)
    elif item > h[0]:
        heapq.heappushpop(h, (tuples[val_col],line))

for (a,b) in h:
    print b

