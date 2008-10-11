# TODO - compute hypergeometric, normalise to pubmed articles (need to get more columns)

import sys
import math

# Assume if x is too small that it is at least 1e-323
def safelog(x):
    if x < 1e-323:
        return -743.74692474082133 # math.log(1e-323)
    return math.log(x)
    
def usage():
    print sys.argv[0], " <disease-profiles> <gene-profiles>"
    print "Compare disease profiles to gene-profiles"

    print "Input format (field1|field2|coc|count1|count2|Total-count2|p)"
    print "coc = x = white balls drawn from urn"
    print "count1 = k = number of balls drawn from the urn"
    print "count2 = m = number of white balls"
    print "Total-count2 = n = number of black balls"
    print "p = p-value"
    print ""
    print "Output format (disease|gene|I|U|L2_count|L2_count_Norm|L2_p|L2_logp|Intersect_L2_count_Norm|Intersect_L2_logp|sumdiff_logp|sum_logcombinedp)"
    print "I : number of intersecting (common) terms"
    print "U : number of union (all) terms"
    print "L2_count:  L2 Distance,  raw term instances"
    print "L2_count_Norm:  L2 Distance,  term instances normalised by total term instances"
    print "L2_p : L2 Distance, hypergeometric p values"
    print "L2_logp : L2 Distance, log p values"
    print "Intersect_L2_count_Norm : Intersecting terms, L2 Distance, normalised counts"
    print "Intersect_L2_logp : Intersecting terms, L2 Distance, log p values"
    print "sumdiff_logp : Sum of differences, log p values"
    print "sum_logcombinedp : Sum,  combined p value"

sep='|'

def main():
    if len(sys.argv) < 3:
        usage()
        sys.exit(-2)

    global sep

    # Currently compute L2 raw distance (probably useless),  normalised (profile shape)
    # Open Disease File

    dprofile_raw = {}
    dprofile_norm = {}
    dprofile_pval = {}
    currterm=''
    dtotal=0.0
    
    print "# disease|gene|I|U|L2_count|L2_count_Norm|L2_p|L2_logp|Intersect_L2_count_Norm|Intersect_L2_logp|sumdiff_logp|sum_logcombinedp"

    disease_file=open(sys.argv[1], 'r')
    for line in disease_file:
        if line[0] == '#':
            continue
        tuple=line.strip().split(sep)
            
        dterm=tuple[0]
        dterm2=tuple[1]
        dcount=int(tuple[2])
        dpval=float(tuple[6])

        if not(currterm):
            currterm = dterm
        
        if not(currterm==dterm):
            process_dterm(currterm, dprofile_raw, dprofile_norm, dtotal, dprofile_pval)
            dprofile_raw = {}
            dprofile_norm = {}
            dprofile_pval = {}
            dtotal=0.0
            currterm=dterm
            
        # Build profile
        dtotal=dtotal+dcount
        dprofile_raw[dterm2]=dcount
        dprofile_pval[dterm2]=dpval
    # Process the last one
    process_dterm(currterm, dprofile_raw, dprofile_norm, dtotal, dprofile_pval)

def process_dterm(currterm, dprofile_raw, dprofile_norm, dtotal, dprofile_pval):
    global sep
    
    # Generate normalised profile
    for key in dprofile_raw:
        dprofile_norm[key] = dprofile_raw[key] / dtotal

    currgene=0
    gtotal=0.0
    gprofile_raw = {}
    gprofile_norm = {}
    gprofile_pval = {}
    
    # Do all the gene processing here
    gfile=open(sys.argv[2], 'r')
    for line in gfile:
        if line[0] == '#':
            continue
        tuple=line.strip().split(sep)
        gene=tuple[0]
        gterm=tuple[1]
        gcount=int(tuple[2])
        gpval=float(tuple[6])

        if not(currgene):
            currgene=gene

        if not(gene==currgene):
            # Compute normalised
            for key in gprofile_raw:
                gprofile_norm[key]=gprofile_raw[key] / gtotal

            # Print Profiles
            pdist_raw=0
            pdist_norm=0.0
            pdist_pval=0.0
            pdist_logpval=0.0
            ipdist_norm=0.0
            ipdist_logpval=0.0
            sumdiff_logp=0.0
            sum_logcombinedp=0.0

            profile_raw=dprofile_raw.copy()
            profile_norm=dprofile_norm.copy()
            profile_pval=dprofile_pval.copy()
            profile_logpval=dprofile_pval.copy()
            iprofile_logpval = {}
            iprofile_norm = {}


            for key in profile_logpval:
                profile_logpval[key]=safelog(profile_logpval[key])
            
            for key in gprofile_raw:
                if key in profile_raw:
                    iprofile_norm[key] = profile_norm[key] - gprofile_norm[key]
                    iprofile_logpval[key] = profile_logpval[key] - safelog(gprofile_pval[key])
                    profile_raw[key] = profile_raw[key] - gprofile_raw[key]
                    profile_norm[key] = profile_norm[key] - gprofile_norm[key]
                    profile_pval[key] = profile_pval[key] - gprofile_pval[key]
                    profile_logpval[key] = profile_logpval[key] - safelog(gprofile_pval[key])
                else:
                    profile_raw[key] = gprofile_raw[key]
                    profile_norm[key] = gprofile_norm[key]
                    profile_pval[key]= gprofile_pval[key]
                    profile_logpval[key]= safelog(gprofile_pval[key])

            ucount = 0
            for key in profile_raw:
                ucount = ucount + 1
                pdist_raw = pdist_raw + (profile_raw[key]**2)
                pdist_norm = pdist_norm + (profile_norm[key]**2)
                pdist_pval = pdist_pval + (profile_pval[key]**2)
                pdist_logpval = pdist_logpval + (profile_logpval[key]**2)
                sumdiff_logp = sumdiff_logp + abs(profile_logpval[key])

            icount = 0
            for key in iprofile_logpval:
                icount = icount + 1
                ipdist_norm=ipdist_norm + (iprofile_norm[key]**2)
                ipdist_logpval=ipdist_logpval + (iprofile_logpval[key]**2)
                sum_logcombinedp = sum_logcombinedp + safelog(dprofile_pval[key] + gprofile_pval[key] - (dprofile_pval[key] * gprofile_pval[key]))
                
            pdist_raw = pdist_raw ** (0.5)
            # Max dist is 2.0
            pdist_norm = (pdist_norm ** (0.5)) / 2.0
            pdist_pval = pdist_pval ** (0.5)
            pdist_logpval = pdist_logpval ** (0.5)

            print currterm+sep+currgene+sep+str(icount)+sep+str(ucount)+sep+str(pdist_raw)+sep+str(pdist_norm)+sep+str(pdist_pval)+sep+str(pdist_logpval)+sep+str(ipdist_norm)+sep+str(ipdist_logpval)+sep+str(sumdiff_logp)+sep+str(sum_logcombinedp)
            
            # Reset gene profile
            currgene=gene
            gtotal=0.0
            gprofile_raw = {}
            gprofile_norm = {}
            gprofile_pval = {}

        gtotal = gtotal+gcount
        gprofile_raw[gterm]=gcount
        gprofile_pval[gterm]=gpval
    gfile.close()

main()

# Read profile into hash
# Create Normalised profile 

# Open Gene Profile files

# For Each gene profile

# copy disease profiles

# Read the gene profile
# For each term,  subtract from hash for each term
# Then,  compute distances
