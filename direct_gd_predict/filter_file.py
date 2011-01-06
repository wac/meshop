import sys
import sets
from sets import Set
import optparse

sep='|'

def usage():
	print "Print all rows of data_file containing a row of pat_file in the first (or num_fields) field(s)"
        print sys.argv[0], " <pat_file> [<data_file> [<num_fields> [YN]]]"
	print "Field delimiter is  '",sep,"'"
	print "Use '-' as data_file or omit for stdin"
	print "num_fields defaults to 1"
	print "YN mode prints all lines,  adding one column at the front of Y or N depending if it matches a row of pat_file"

def main():
	parser = optparse.OptionParser()
	parser.add_option("--YN", "-y", "--yn", dest="yesno_mode", default=False, 
				action="store_true")
	parser.add_option("-n", "--num-fields", dest="num_fields", 
				default=1, action="store", type="int")
	parser.add_option("-f", "--start-field", "--field", dest="start_field",
				default=0, action="store", type="int")
	(options, args) = parser.parse_args(sys.argv)

	options.num_fields=1
	if (len(args) >= 3):
		patfile=open(args[1])
		if (args[2] == '-'):
			datafile=sys.stdin
		else:
			datafile=open(args[2])
		if (len(args) > 3):
			options.num_fields=int(args[3])
			if (len(args) > 4) and (args[4] == "YN"):
				options.yesno_mode=True
	elif (len(args) == 2):
		patfile=open(args[1])
		datafile=sys.stdin
        else:     
		usage()
		sys.exit(-1)

	patterns=Set()

	for line in patfile:
		patterns.add(line.strip())
	patfile.close()
	
	for line in datafile:
		if line[0] == '#':
			continue
		tuple=line.strip().split(sep)
		if len(tuple) < (options.num_fields):
			continue
		if sep.join(tuple[options.start_field:options.start_field+options.num_fields]) in patterns:
			if options.yesno_mode == True:
				print "Y"+sep+line,
			else:
				print line,
		else:
			if options.yesno_mode == True:
				print "N"+sep+line,

main()
