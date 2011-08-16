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

    print "Input format (field1|field2|coc|count1|count2|Total-count2|p|tfidf)"
    print "coc = x = white balls drawn from urn"
    print "count1 = k = number of balls drawn from the urn"
    print "count2 = m = number of white balls"
    print "Total-count2 = n = number of black balls"
    print "p = p-value"
    print "tfidf = term frequency-inverse document frequency"
    print ""
    print "Output format (disease|gene|D|G|I|U|L2_count|L2_count_Norm|L2_p|L2_logp|Intersect_L2_count_Norm|Intersect_L2_logp|sumdiff_logp|sum_logcombinedp|cosine_count_Norm|cosine_p|cosine_tfidf)"
    print "D : number of disease terms"
    print "G : number of gene terms"
    print "I : number of intersecting (common) terms"
    print "U : number of union (all) terms"
    print "L2_count:  L2 Distance,  raw term instances"
    print "L2_count_Norm:  L2 Distance,  term instances normalised by total term instances (term fractions)"
    print "L2_p : L2 Distance, hypergeometric p values"
    print "L2_logp : L2 Distance, log p values"
    print "Intersect_L2_count_Norm : Intersecting terms, L2 Distance, normalised counts"
    print "Intersect_L2_logp : Intersecting terms, L2 Distance, log p values"
    print "sumdiff_logp : Sum of differences, log p values"
    print "sum_logcombinedp : Sum,  combined p value"
    print "cosine_count_Norm: Cosine Distance of normalised counts"
    print "cosine_p: Cosine Distance of p-values"
    print "cosine_tfidf: Cosine Distance of tf-idf values"

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
    dprofile_tfidf = {}
    currterm=''
    dtotal=0.0
    
    print "# disease|gene|D|G|I|U|L2_count|L2_count_Norm|L2_p|L2_logp|Intersect_L2_count_Norm|Intersect_L2_logp|sumdiff_logp|sum_logcombinedp|cosine_count_Norm|cosine_p|cosine_tfidf"

    disease_file=open(sys.argv[1], 'r')
    for line in disease_file:
        if line[0] == '#':
            continue
        tuple=line.strip().split(sep)
            
        dterm=tuple[0]
        dterm2=tuple[1]
        dcount=int(tuple[2])
        dpval=float(tuple[6])
	dtfidf=float(tuple[7])

        if not(currterm):
            currterm = dterm
        
        if not(currterm==dterm):
            process_dterm(currterm, dprofile_raw, dtotal, dprofile_pval, dprofile_tfidf)
            # Reset Disease profile
            dprofile_raw = {}
            dprofile_pval = {}
            dprofile_tfidf = {}
            dtotal=0.0
            currterm=dterm
            
        # Build profile
        dtotal=dtotal+dcount
        dprofile_raw[dterm2]=dcount
        dprofile_pval[dterm2]=dpval
        dprofile_tfidf[dterm2]=dtfidf
    # Process the last one
    process_dterm(currterm, dprofile_raw, dtotal, dprofile_pval, dprofile_tfidf)

def compare_gdterm(currgene, currterm, dprofile_raw, dtotal, dprofile_norm, dprofile_pval, dprofile_tfidf, cosine_norm_dmag, cosine_p_dmag, cosine_tfidf_dmag, gprofile_raw, gtotal, gprofile_norm, gprofile_pval, gprofile_tfidf):
    cosine_norm_gmag=0.0
    cosine_p_gmag=0.0
    cosine_tfidf_gmag=0.0

    # Compute normalised
    for key in gprofile_raw:
        gprofile_norm[key]=float(gprofile_raw[key]) / gtotal
        cosine_norm_gmag=cosine_norm_gmag+(gprofile_norm[key]*gprofile_norm[key])
        cosine_p_gmag=cosine_p_gmag+(gprofile_pval[key]*gprofile_pval[key])
        cosine_tfidf_gmag=cosine_tfidf_gmag+(gprofile_tfidf[key]*gprofile_tfidf[key])

    cosine_norm_gmag=math.sqrt(cosine_norm_gmag)
    cosine_p_gmag=math.sqrt(cosine_p_gmag)
    cosine_tfidf_gmag=math.sqrt(cosine_tfidf_gmag)

    # Print Profiles
    pdist_raw=0
    pdist_norm=0.0
    pdist_pval=0.0
    pdist_logpval=0.0
    ipdist_norm=0.0
    ipdist_logpval=0.0
    sumdiff_logp=0.0
    sum_logcombinedp=0.0
    
    cosine_norm=0.0
    cosine_p=0.0
    cosine_tfidf=0.0
            
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
            cosine_norm = cosine_norm+(dprofile_norm[key]*gprofile_norm[key])
            cosine_p = cosine_p+(dprofile_pval[key]*gprofile_pval[key])
            cosine_tfidf = cosine_tfidf+(dprofile_tfidf[key]*gprofile_tfidf[key])
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

    cosine_norm = cosine_norm/( cosine_norm_gmag * cosine_norm_dmag )
    if ( cosine_p_gmag * cosine_p_dmag == 0):
        sys.stderr.write("Profile computation Error ("+currterm+sep+currgene+"): cosine_p_gmag ("+str(cosine_p_gmag)+") * cosine_p_dmag ("+str(cosine_p_dmag)+") == 0\n")
        sys.exit(1)

    cosine_p = cosine_p/( cosine_p_gmag * cosine_p_dmag )
    cosine_tfidf = cosine_tfidf/( cosine_tfidf_gmag * cosine_tfidf_dmag )

    print currterm+sep+currgene+sep+str(len(dprofile_raw))+sep+str(len(gprofile_raw))+sep+str(icount)+sep+str(ucount)+sep+str(pdist_raw)+sep+str(pdist_norm)+sep+str(pdist_pval)+sep+str(pdist_logpval)+sep+str(ipdist_norm)+sep+str(ipdist_logpval)+sep+str(sumdiff_logp)+sep+str(sum_logcombinedp)+sep+str(cosine_norm)+sep+str(cosine_p)+sep+str(cosine_tfidf)

            
def process_dterm(currterm, dprofile_raw, dtotal, dprofile_pval, dprofile_tfidf):
    global sep
            
    cosine_norm_dmag=0.0
    cosine_p_dmag=0.0
    cosine_tfidf_dmag=0.0
    dprofile_norm = {}

    # Generate normalised profile
    for key in dprofile_raw:
        dprofile_norm[key] = float(dprofile_raw[key]) / dtotal
                
        cosine_norm_dmag=cosine_norm_dmag+(dprofile_norm[key]*dprofile_norm[key])
        cosine_p_dmag=cosine_p_dmag+(dprofile_pval[key]*dprofile_pval[key])
        cosine_tfidf_dmag=cosine_tfidf_dmag+(dprofile_tfidf[key]*dprofile_tfidf[key])

    cosine_norm_dmag=math.sqrt(cosine_norm_dmag)
    cosine_p_dmag=math.sqrt(cosine_p_dmag)
    cosine_tfidf_dmag=math.sqrt(cosine_tfidf_dmag)

    currgene=0
    gtotal=0.0
    gprofile_raw = {}
    gprofile_norm = {}
    gprofile_pval = {}
    gprofile_tfidf = {}
    
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
        gtfidf=float(tuple[7])

        if not(currgene):
            currgene=gene

        if not(gene==currgene):
            compare_gdterm(currgene, currterm, dprofile_raw, dtotal, dprofile_norm, dprofile_pval, dprofile_tfidf, cosine_norm_dmag, cosine_p_dmag, cosine_tfidf_dmag, gprofile_raw, gtotal, gprofile_norm, gprofile_pval, gprofile_tfidf)
            
            # Reset gene profile
            currgene=gene
            gtotal=0.0
            gprofile_raw = {}
            gprofile_norm = {}
            gprofile_pval = {}
            gprofile_tfidf = {}

        gtotal = gtotal+gcount
        gprofile_raw[gterm]=gcount
        gprofile_pval[gterm]=gpval
        gprofile_tfidf[gterm]=gtfidf
    gfile.close()
    # Process the last gene
    compare_gdterm(currgene, currterm, dprofile_raw, dtotal, dprofile_norm, dprofile_pval, dprofile_tfidf, cosine_norm_dmag, cosine_p_dmag, cosine_tfidf_dmag, gprofile_raw, gtotal, gprofile_norm, gprofile_pval, gprofile_tfidf)
main()

