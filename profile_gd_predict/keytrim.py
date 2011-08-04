import sys
import heapq
import optparse

# Splits each lines based on sep
# ignores and prints lines starting with '#'
# Keeps the top 'heapsize' lines,  based on 'val_col', for each set for 'key_col'

sep='|'
key_col=0
val_col=1

old_key=False

h=[]

parser = optparse.OptionParser()
parser.add_option("-n", dest="heapsize",
                  default=50, action="store", type="int")
parser.add_option("-R", "--random", dest="use_random",
                  default=False, action="store_true")

(options, args) = parser.parse_args(sys.argv)

if (len(args) > 1):
    options.heapsize=int(args[1])

if (len(args) > 2):
    key_col=int(args[2])

if (len(args) > 3):
    val_col=int(args[3])


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

    if (len(h) < options.heapsize):
        heapq.heappush(h, item)
    elif item > h[0]:
        heapq.heappushpop(h, (tuples[val_col],line))

for (a,b) in h:
    print b

