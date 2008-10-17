import sys

last_pmid=-1
sep='|'
prevline=""
firstauthorYN='Y'

for line in sys.stdin:
    line=line.strip()
    tuple=line.split(sep)
    curr_pmid=tuple[0]
    if last_pmid==-1:
        last_pmid=curr_pmid
        prevline=line
    else:
        if last_pmid==curr_pmid:
            print prevline+sep+"N"+sep+firstauthorYN
            firstauthorYN='N'
        else:
            print prevline+sep+"Y"+sep+firstauthorYN
            firstauthorYN='Y'
            
        prevline=line
        
print prevline+sep+"Y"+sep+firstauthorYN
