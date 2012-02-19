import sys
import heapq
import optparse
from bitcount2 import bitcount

hasher={}
profile={}
key_list=[]

key_col=0

def usage():
    print sys.argv[0]," [profile_file]"
    print "  Load the profile lines from profile_file"
    print "  Hash function uses the features listed in profile_file"
    print "    and tests for p-value greater/less than or equal (0/1)"
    print "  Hash all the profiles from stdin" 
    exit(1)

def do_hash(hasher, p, key_list):
    hashval=""
    
    #    for k, v in hasher.iteritems():
    for k in key_list:
        v=hasher[k]
        if k in p and p[k] < v:
            hashval=hashval+"1"
        else:
            hashval=hashval+"0"
    return hashval

sep='|'
key_col=0
#feature_col=1
#score_col=6
in_feature_col=0
in_score_col=1
process_feature_col=1
process_score_col=6


parser = optparse.OptionParser()
#parser.add_option("-n", dest="heapsize",
#                  default=50, action="store", type="int")
#parser.add_option("-R", "--random", dest="use_random",
#                  default=False, action="store_true")

(options, args) = parser.parse_args(sys.argv)

if (len(args) > 1):
    profile_filename=args[1]
else:
    usage()

for line in open(profile_filename):
    if line[0]=='#':
        continue
    tuples=line.strip().split(sep)
    key=tuples[in_feature_col]
    key_list.append(key)
    hasher[key]=tuples[in_score_col]

curr_profile={}
old_key=""

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
        hashval=do_hash(hasher, curr_profile, key_list)
        hashval_int=int(hashval, 2)
        print old_key+sep+hashval+sep+str(hashval_int)+sep+str(bitcount(hashval_int))
        curr_profile={}
        old_key=curr_key

    curr_profile[tuples[process_feature_col]]=tuples[process_score_col]

hashval=do_hash(hasher, curr_profile, key_list)
hashval_int=int(hashval, 2)
print old_key+sep+hashval+sep+str(hashval_int)+sep+str(bitcount(hashval_int))

