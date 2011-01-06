# Get the percentile of the score among other scores input
import sys

n = 0
i = 0
j = 0
file=sys.stdin

if len(sys.argv) < 2:
	print sys.argv[0], "[score]"
	print "lists percentile (fraction of items <= score) of all scores in stdin"
	exit(1)

score=sys.argv[1]

for line in file:
	n = n + 1
	if score > line:
		i = i + 1
	if score < line:
		j = j + 1

print "score greater than" 
print float(i)/float(n)
print i, "/", n
print "score less than" 
print float(j)/float(n)
print j, "/", n
