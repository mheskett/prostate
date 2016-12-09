#!/usr/bin/bash
## Asia Mitchell - last update: Oct 15, 2015
## UASAGE:  ./align_fastq.sh fastq1 fastq2 desired_output_name
export PATH=$PATH:/opt/installed/:/usr/bin/

################
## Setup temp directory, all output files will be located here
out_dir='/home/exacloud/lustre1/SpellmanLab/heskett/prostate_neoantigen/fastq/'
################

DATE=`date +%Y-%m-%d`
random=$RANDOM

fq1=$1
fq2=$2
name=$3
sample=1 ## since I previously combined fq files from 2 different lanes, readgroups dont matter
plat=illumina

echo $fq1
echo $fq2

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
 if [ $? -eq 0 ]
 	then
 		/opt/installed/bwa mem -t 24 -R $readgrp $ref $fq1 $fq2 > $out_dir$name.sam
 	else
 		echo 'Exit at FASTQ to SAM:'$?
 		exit
 fi
################
## Sort SAM & Convert SAM to BAM
################
 if [ $? -eq 0 ]
 	then
 		/usr/lib/jvm/jre-1.7.0/bin/java -jar /opt/installed/picard/picard-tools-1.110/SortSam.jar \
 			INPUT=$out_dir$name.sam \
 			OUTPUT=$out_dir$name.sorted.bam \
 			VALIDATION_STRINGENCY=LENIENT \
 			SORT_ORDER=coordinate 
 	else
 		echo 'Exit at Sort SAM, SAM to BAM:'$?
 		exit
 fi
################
##MAP AND MARK DUPLICATES	
################
if [ $? -eq 0 ]
	then
		 /usr/lib/jvm/jre-1.7.0/bin/java -jar /opt/installed/picard/picard-tools-1.110/MarkDuplicates.jar \
			VALIDATION_STRINGENCY=SILENT \
			ASSUME_SORTED=true \
			REMOVE_DUPLICATES=true \
			INPUT=$out_dir$name.sorted.bam \
			OUTPUT=$out_dir$name.sorted.dedup.bam \
			METRICS_FILE=$out_dir$name.metrics
	else
		echo 'Exit at MAP AND MARK DUPLICATES:'$?
		exit
fi
###############
#Build Index
###############
if [ $? -eq 0 ]
	then
		/usr/lib/jvm/jre-1.7.0/bin/java -jar /opt/installed/picard/picard-tools-1.110/BuildBamIndex.jar \
		  INPUT=$out_dir$name.sorted.dedup.bam \
	 	  OUTPUT=$out_dir$name.sorted.dedup.bam.bai
	else
		echo 'Exit at MAP AND MARK DUPLICATES - BuildIndex:'$?
		exit
fi

################
#RECALIBRATE BASE QUALITY SCORES
################
if [ $? -eq 0 ]
        then
                /usr/lib/jvm/jre-1.7.0/bin/java -jar /opt/installed/GATK/GenomeAnalysisTK-3.2.jar \
                        -T BaseRecalibrator \
                        -R $ref \
                        -I $out_dir$name.sorted.dedup.bam \
                        -rf BadCigar \
                        -l INFO \
                        --default_platform illumina \
                        -knownSites $dbsnp \
                        -cov QualityScoreCovariate \
                        -cov CycleCovariate \
                        -cov ContextCovariate \
                        -cov ReadGroupCovariate \
                        --disable_indel_quals \
                        -o $out_dir$name.recaltable
        else
                echo 'Exit at GATK BaseRecalibrator: '$?
                exit
fi
################
#Print Reads
################
if [ $? -eq 0 ]
        then
                /usr/lib/jvm/jre-1.7.0/bin/java -jar /opt/installed/GATK/GenomeAnalysisTK-3.2.jar \
                        -T PrintReads \
                        -R $ref \
                        -I $out_dir$name.sorted.dedup.bam \
                        -l INFO \
                        -rf BadCigar \
                        -BQSR $out_dir$name.recaltable  \
                        -o $out_dir$name.bam
        else
                echo 'Exit at GATK PrintReads: '$?
        exit
fi
################
#Build Bam Index
################
if [ $? -eq 0 ]
        then
                 /usr/lib/jvm/jre-1.8.0/bin/java -jar /opt/installed/picard/picard-tools-1.110/BuildBamIndex.jar \
                         VALIDATION_STRINGENCY=LENIENT \
                         INPUT=$out_dir$name.bam \
                         OUTPUT=$out_dir$name.bam.bai
        else
                echo 'Exit at Final BuildIndex:'$?
        exit
fi
##############
if [ $? -eq 0 ]
	then
		 /opt/installed/samtools flagstat $out_dir$name.bam > $out_dir$name.flagstat
	else
		echo 'Exit at FLAGSTAT:'$?
		exit
fi

exit
