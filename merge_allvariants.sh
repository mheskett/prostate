#!/usr/bin/bash
# merge_allvariants.sh normal tumor 
export PATH=$PATH:/opt/installed/:/usr/bin/
export PATH=$PATH:/home/groups/atlas/mitcheas/Tools/
export PATH=$PATH:/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/
export PERL5LIB=/home/groups/atlas/mitcheas/Tools/vcftools_0.1.12b/perl/

normal=$1
tumor=$2
out_dir='/home/exacloud/lustre1/users/mitcheas/VHL/Merge/'$tumor'/VCF/'
tumor_dir='/home/exacloud/lustre1/users/mitcheas/VHL/Merge/'$tumor'/VCF/'
filt='Filtered/ANNOVAR/NonSynonymous/'

## Remove existing files
rm $out_dir$normal-$tumor.nonsyn
rm $out_dir$normal-$tumor.snv.vcf
rm $out_dir$normal-$tumor.snv.vcf.gz
rm $out_dir$normal-$tumor.nonsyn.list
rm $out_dir$normal-$tumor.nonsyn.tmp
rm $out_dir$normal-$tumor.nonsyn.bed
rm $out_dir$normal-$tumor.nonsyn.bed.gz
rm $out_dir$normal-$tumor.filt.snv.vcf
rm $out_dir$normal-$tumor.filt.ann.snv.vcf

## Merge filtered per chromosome callstats files into 1 file
cat $tumor_dir$filt$normal-$tumor.1.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.2.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.3.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.4.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.5.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.6.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.7.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.8.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.9.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.10.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.11.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.12.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.13.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.14.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.15.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.16.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.17.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.18.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.19.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.20.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.21.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.22.out.nonsyn \
	$tumor_dir$filt$normal-$tumor.X.out.nonsyn > \
	$out_dir$normal-$tumor.nonsyn

## Merge filtered per chromosome vcf files into 1 file
/home/groups/atlas/mitcheas/Tools/vcftools_0.1.12b/bin/vcf-concat \
	$tumor_dir$normal-$tumor-1.snv.vcf \
	$tumor_dir$normal-$tumor-2.snv.vcf \
	$tumor_dir$normal-$tumor-3.snv.vcf \
	$tumor_dir$normal-$tumor-4.snv.vcf \
	$tumor_dir$normal-$tumor-5.snv.vcf \
	$tumor_dir$normal-$tumor-6.snv.vcf \
	$tumor_dir$normal-$tumor-7.snv.vcf \
	$tumor_dir$normal-$tumor-8.snv.vcf \
	$tumor_dir$normal-$tumor-9.snv.vcf \
	$tumor_dir$normal-$tumor-10.snv.vcf \
	$tumor_dir$normal-$tumor-11.snv.vcf \
	$tumor_dir$normal-$tumor-12.snv.vcf \
	$tumor_dir$normal-$tumor-13.snv.vcf \
	$tumor_dir$normal-$tumor-14.snv.vcf \
	$tumor_dir$normal-$tumor-15.snv.vcf \
	$tumor_dir$normal-$tumor-16.snv.vcf \
	$tumor_dir$normal-$tumor-17.snv.vcf \
	$tumor_dir$normal-$tumor-18.snv.vcf \
	$tumor_dir$normal-$tumor-19.snv.vcf \
	$tumor_dir$normal-$tumor-20.snv.vcf \
	$tumor_dir$normal-$tumor-21.snv.vcf \
	$tumor_dir$normal-$tumor-22.snv.vcf \
	$tumor_dir$normal-$tumor-X.snv.vcf > \
	$out_dir$normal-$tumor.snv.vcf

## Compress and Index VCF file
/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/bgzip $out_dir$normal-$tumor.snv.vcf
/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/tabix -p vcf $out_dir$normal-$tumor.snv.vcf.gz

## Make list file of filtered exonic nonsynonymous variants in TABIX region format
awk -F'[\t ]' '{print $5":"$6"-"$7}' $out_dir$normal-$tumor.nonsyn > $out_dir$normal-$tumor.nonsyn.list

## Make a BED file of filtered exonic nonsynonymous variants
awk -F'[\t ]' '{print $5"\t"$6"\t"$7"\t"$4}' $out_dir$normal-$tumor.nonsyn > $out_dir$normal-$tumor.nonsyn.tmp
echo "#CHR     FROM   TO      ANN" > $out_dir$normal-$tumor.nonsyn.bed 
cut -d':' -f1 $out_dir$normal-$tumor.nonsyn.tmp >> $out_dir$normal-$tumor.nonsyn.bed
rm  $out_dir$normal-$tumor.nonsyn.tmp

## Compress and Index BED file
/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/bgzip $out_dir$normal-$tumor.nonsyn.bed
/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/tabix -p bed -s 1 -b 2 -e 3 $out_dir$normal-$tumor.nonsyn.bed.gz

## Run vcftools to filter vcf by bed file of snvs to keep
#/home/groups/atlas/mitcheas/Tools/vcftools/src/cpp/vcftools \
#	--vcf $out_dir$normal-$tumor.snv.vcf.gz \
#	--bed $out_dir$normal-$tumor.nonsyn.bed.gz \
#	--recode \
#	--out $out_dir$normal-$tumor.filt.snv.vcf 

## Run tabix to filter vcf by bed file of snvs to keep
#/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/tabix -fR $out_dir$normal-$tumor.snv.vcf.gz $out_dir$normal-$tumor.nonsyn.bed.gz
#/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/bgzip -d $out_dir$normal-$tumor.filt.snv.vcf.gz

##----- FILTER VCF -----
		
## Write VCF header to outfile		
/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/tabix -h $out_dir$normal-$tumor.snv.vcf.gz chr1:1 > $out_dir$normal-$tumor.filt.snv.vcf

## Run tabix to filter vcf by bed file of snvs to keep
for line in $(cat $out_dir$normal-$tumor.nonsyn.list); 
do
	/home/groups/atlas/mitcheas/Tools/htslib-1.2.1/tabix -f $out_dir$normal-$tumor.snv.vcf.gz $line >> $out_dir$normal-$tumor.filt.snv.vcf;
done

## Annotate filtered VCF with gene names
cat $out_dir$normal-$tumor.filt.snv.vcf | /home/groups/atlas/mitcheas/Tools/vcftools_0.1.12b/bin/vcf-annotate \
	-a $out_dir$normal-$tumor.nonsyn.bed.gz \
	-d key=INFO,ID=GN,Number=1,Type=Integer,Description='Gene' \
	-c CHROM,FROM,TO,INFO/GN > $out_dir$normal-$tumor.filt.ann.snv.vcf

