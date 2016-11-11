import string, re, argparse

# FUNCTION: READ_VCF(FILENAME)
# Reads all lines of an input VCF file
# Removes header lines of VCF
def read_vcf(Filename):
	Filename = open(Filename, 'U')
	alllines = Filename.readlines()
	outlist = []
	for line in alllines:
		if not re.match('##', line): ## removes only header lines beginning with a double hash symbol
			line = line.rstrip()
			line = string.split(line, '\t')
		outlist.append(line)
	return outlast					## returns a nested list
	
# FUNCTION: vcf_dict = vcf_to_dict(vcf_wo_header) 
# Input file is a list of lines from a VCF file
# First line is the header
# Subsequent lines are variants and their annotations
# AD = allelic depth [wt reads, mut reads]
# GN = gene
# v[chr1-5555] = {chrom: 1, pos: 5555, GN: 'YFG', AD: [21,1]}
# Output is a dictionary
# VCF header:
# #CHROM  POS ID  REF ALT QUAL FILTER INFO FORMAT TUMOR  NORMAL
def vcf_to_dict(vcf_wo_header, tumorID):	## add parameter giving sample ID for TUMOR/NORMAL, if needed
	vcf_dict = {}
	header = vcf_wo_header[0]
	variants = vcf_wo_header[1:]
	
	# Get index of INFO, FORMAT and TUMOR in header
	h_info_idx = [i for i,x in enumerate(header) if x == 'INFO'][0]
	h_frmt_idx = [i for i,x in enumerate(header) if x == 'FORMAT'][0]
	h_tmr_idx = [i for i,x in enumerate(header) if x == tumorID][0]
	
	# GENERATE DICTIONARY
	for v in variants:
		chrom = v[0]
		pos = v[1]
		ref = v[3]
		alt = v[4]
		
		## We want to remove indels... so if indel, skip it
		if len(ref) > 1 or len(alt) >1:
			continue
		
		v_idx = chrom +'-'+pos 		## Create key for adding variant to dictionary
		
		info = v[h_info_idx]
		format = v[h_frmt_idx]
		tumor = v[h_tmr_idx]
		
		# If GN in INFO, get index & info
		# If GN not in INFO, gene is blank
		info = string.split(info, ';')		## Split the 'INFO' block by ';' delimiter
		gene = ''
		
		for x in info:
			if re.match('GN=', x):
				gene = string.split(x, '=')[1]
		
		format = string.split(format, ':')		## Split the 'FORMAT' block by ':' delimiter
		tumor = string.split(tumor, ':')		## Split the 'TUMOR' block by ':' delimiter
		
		# Get index and info AD in FORMAT
		# Convert values in AD to integers
		ad_idx = [i for i,x in enumerate(format) if x == 'AD'][0]
		ad = string.split(tumor[ad_idx], ',')
		ad = [int(i) for i in ad]
		
		if sum(ad) < 15:	## We want to remove variants with tumor depth below 15 reads
			continue
		# Add variant to dictionary
		if v_idx not in vcf_dict.keys():
			vcf_dict[v_idx] = {}
			
		vcf_dict[v_idx]['CHROM'] = chrom
		vcf_dict[v_idx]['POS'] = pos
		vcf_dict[v_idx]['GN'] = gene
		vcf_dict[v_idx]['AD'] = ad
		
	return(vcf_dict)	## Returns a dictionary where "chrom-pos" are the keys

## Get command line arguments
parser.add_argument('-vcf', action='store', required=True, dest='vcf', help='VCF file')

# Open and read input files
vcf_wo_header = read_vcf(args.vcf)
vcf_dict = vcf_to_dict(vcf_wo_header, 'TUMOR')
