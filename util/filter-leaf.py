# Given a parent-child list,  filter remove all tuples with a term where another tuple # has a child term
# Group by first column

import sys


if len(sys.argv) < 2:
	print sys.argv[0], "[parent-child file]"
	print "Filter all tuples having a parent term when a tuple with a child term exists"
	exit(1)

sep="|"

parents = { }

file=open(sys.argv[1], 'r')

# Load term-child data from stdin
for line in file:
	cols=line.strip().split(sep)
	term=cols[0]
	child=cols[1]
	if child in parents:
		parents[child].append(term)
	else:
		parents[child]= [ term ]



file=sys.stdin

curr_group = None
curr_lines = {}
covered = set( [] )

for line in file:
	fields = line.strip().split(sep)
	group_field=fields[0]
	if (curr_group == None):
		curr_group = group_field
	if (curr_group != group_field):
		# new group - print the old result
		for i,j in curr_lines.iteritems():
			print j,
		# reset for next group
		curr_group=group_field
		curr_lines = {}
		covered = set ( [] )
	term=fields[1]
	if term not in covered:
		# remove all existing term lines that parents of the term
		for parent_term in parents[term]:
			if parent_term in curr_lines:
				del curr_lines[parent_term]
		# add and update the covered terms set
		covered.update(parents[term])
		curr_lines[term]=line
	# otherwise, term is already covered == don't add

# print the last group
for i,j in curr_lines.iteritems():
	print j,