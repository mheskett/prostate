#!/usr/bin/bash
## Asia Mitchell - last update: Oct 15, 2015
## UASAGE:  ./align_fastq.sh fastq(with path) filename(without.fq) sample platform
export PATH=$PATH:/opt/installed/:/usr/bin/

################
## Setup temp directory, all output files will be located here
tmp_dir='/mnt/lustre1/SpellmanLab/mitcheas/VHL/Tmp/'
################

fq=$1
name=$2
sample=$3
plat=$4

echo $fq
outbam=$tmp_dir$name'.bam'
outsam=$tmp_dir$name'.sam'


### ALL REFERENCES HAVE 'CHR' PREFIX
ref='/mnt/tempwork/SpellmanLab/mitcheas/RefUCSC/g1k/Prefix/g1k_v37_prefix.fa'
readgrp='@RG\tID:'$name'\tSM:'$sample'\tPL:'$plat'\tLB:'$name
indel='/mnt/tempwork/SpellmanLab/mitcheas/1000Genomes/1000G_phase1.indels.hg19.sites.vcf'
dbsnp='/mnt/tempwork/SpellmanLab/mitcheas/DBSnp/dbsnp_138.hg19.vcf'
#cosmic='/home/groups/atlas/mitcheas/COSMIC/CosmicCodingMuts.prefix.sorteds.vcf'

################
## STEP 1: Align FASTQ using BWA MEM
## FASTQ to SAM
################
# if [ $? -eq 0 ]
# 	then
# 		/opt/installed/bwa mem -t 24 -Map -R $readgrp $ref $fq > $outsam
# 	else
# 		echo 'Exit at FASTQ to SAM:'$?
# 		exit
# fi
################
## Sort SAM & Convert SAM to BAM
################
# if [ $? -eq 0 ]
# 	then
# 		out=$tmp_dir$name'.sorted.bam'
# 		/usr/bin/java -jar /opt/installed/picard/picard-tools-1.110/SortSam.jar \
# 			INPUT=$outsam \
# 			OUTPUT=$out \
# 			VALIDATION_STRINGENCY=LENIENT \
# 			SORT_ORDER=coordinate 
# 	else
# 		echo 'Exit at Sort SAM, SAM to BAM:'$?
# 		exit
# fi
################
## STEP 2: MAP AND MARK DUPLICATES	
################
if [ $? -eq 0 ]
	then
		infile=$tmp_dir$name'.sorted.bam'
#		infile=$out
		out=$tmp_dir$name'.sorted.dedup.bam'
		metric=$out'.metrics'
		
		/usr/bin/java -jar /opt/installed/picard/picard-tools-1.110/MarkDuplicates.jar \
			VALIDATION_STRINGENCY=SILENT \
			ASSUME_SORTED=true \
			REMOVE_DUPLICATES=true \
			INPUT=$infile \
			OUTPUT=$out \
			METRICS_FILE=$metric
	else
		echo 'Exit at MAP AND MARK DUPLICATES:'$?
		exit
fi
###############
###############
if [ $? -eq 0 ]
	then
		infile=$out
		out=$out'.bai'
		/usr/bin/java -jar /opt/installed/picard/picard-tools-1.110/BuildBamIndex.jar \
			INPUT=$infile \
			OUTPUT=$out
#		rm $tmp_dir$name.sorted.bam
#		rm $tmp_dir$name.sorted.bam.bai
	else
		echo 'Exit at MAP AND MARK DUPLICATES - BuildIndex:'$?
		exit
fi
################	
## STEP 3: PERFORM LOCAL REALIGNMENT AROUND INDELS
## Create targets for realignment
################
if [ $? -eq 0 ]
	then
		target=$tmp_dir$name'.target_intervals.list'
		/usr/bin/java -jar /opt/installed/GATK/GenomeAnalysisTK-3.2.jar \
			-T RealignerTargetCreator \
			-R $ref \
			-I $infile \
			-known $indel \
			-nt 12 \
			-o $target 
	else
		echo 'Exit at GATK RealignerTargetCreator:'$?
		exit
fi	
################
## Perform realignment around targets	
################	
if [ $? -eq 0 ]
	then
		out=$tmp_dir$name'.sorted.dedup.order.ra.bam'
		/usr/bin/java -jar /opt/installed/GATK/GenomeAnalysisTK-3.2.jar \
			-T IndelRealigner \
			-R $ref \
			-rf NotPrimaryAlignment \
			-I $infile \
			-targetIntervals $target \
			-known $indel \
			-o  $out \
			--filter_bases_not_stored
	else
		echo 'Exit at GATK IndelRealigner:'$?
		exit
fi
################	
## Build BAM index
################	
if [ $? -eq 0 ]
	then	
		infile=$out
		out=$out'.bai'
		/usr/bin/java -jar /opt/installed/picard/picard-tools-1.110/BuildBamIndex.jar \
			VALIDATION_STRINGENCY=LENIENT \
			INPUT= $infile \
			OUTPUT=$out
#		rm $tmp_dir$name.sorted.dedup.order.bam
#		rm $tmp_dir$name.sorted.dedup.order.bam.bai
	else
		echo 'Exit at GATK IndelRealigner - BuildIndex:'$?
		exit	
fi

################	
################
if [ $? -eq 0 ]
	then
		 /opt/installed/samtools flagstat $outbam > $tmp_dir$name.flagstat
	else
		echo 'Exit at FLAGSTAT:'$?
		exit
fi
################	
## If you want to copy your final, aligned BAM and BAI to a different directory
## uncomment this section and change $FINAL_DIR.
################

final_dir='/home/groups/atlas/mitcheas/VHL/BAMs/'
scp $outbam $final_dir$name.bam
scp $outbam.bai $final_dir$name.bam.bai

################	
## If you want to remove outfiles in your temp directory, uncomment this section.
################
#rm $outbam
#rm $outbam.bai
#rm $tmp_dir$name.recaltable 
#rm $tmp_dir$name.target_intervals.list 
#rm $tmp_dir$name.metrics
