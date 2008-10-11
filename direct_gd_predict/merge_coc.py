import sys

def usage():
	print "Join co-occurrence counts with total counts for each field"
        print "Can then be used in R via phyper()"
        print sys.argv[0], " <coc_file> <field1_counts> <field2_counts> <total> [-r]"

        print "<coc_file>: Co-occurrence file with format field1|field2|coc (or coc|field1|field2 if -r is specified)"
        print "<field1_counts>: File with counts from the field1 with format field1|count1"
        print "<field2_counts>: File with coutns from field 2 with format field2|count2"
        print "<total>: Total number of pubmed articles considered"
	print "-r : reversed input format (coc|field1|field2)"
        print "\nOutput is  field1|field2|coc|count1|count2|Total-count2"
	print "coc = x = white balls drawn from urn"
	print "count1 = k = number of balls drawn from the urn"
	print "count2 = m = number of white balls"
	print "Total-count2 = n = number of black balls"
	print "Assumes that field1_counts and field2_counts can fit in python dictionaries in memory"
	
sep='|'

def main():
	if (len(sys.argv) < 5):
		usage()
		sys.exit(-1)
	
	cocfile=open(sys.argv[1])
	file1=open(sys.argv[2])
	file2=open(sys.argv[3])
	total=int(sys.argv[4])

	reversed = ((len(sys.argv) > 5) and (sys.argv[5] == '-r'))

#	print "TOTAL:"+str(total)
	
	f1 = {}
	for line in file1:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		f1[tuple[0]]=tuple[1]
	
	f2 = {}
	for line in file2:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		f2[tuple[0]]=tuple[1]


	for line in cocfile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		if reversed:
			coc=tuple[0]
			field1=tuple[1]
			field2=tuple[2]
		else:
			field1=tuple[0]
			field2=tuple[1]
			coc=tuple[2]
		#		print "Field1:"+str(field1)
		#		print "Field2:"+str(field2)
		#		print "Field3:"+str(coc)
		
		#		print "f2[]:"+f2[field2]
#		outline='"'+str(field1)+'"'+sep+'"'+str(field2)+'"'
		outline=str(field1)+sep+str(field2)
		outline=outline+sep+str(coc)
		outline=outline+sep+str(f1[field1])
		outline=outline+sep+str(f2[field2])+sep+str(total-int(f2[field2]))
		print outline
		

main()
