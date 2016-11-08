#!/bin/bash

# Given an agilent bait capture file, name of a gene of interest, and list of bam files
# produce visualizations on coverage using DiagnoseTargets (GATK) and python plotting

agilent=$1 # currently using Agilent_v5_covered.bed
geneName=$2
bamList=$3
random=$RANDOM # currently using /home/exacloud/lustre1/users/peto/mutation_pipeline/genomes/human/g1k/human_g1k_v37.fasta
ref=$4
DATE=`date +%Y-%m-%d`

if [ $# -eq 4 ] 
then

	## grep all the bait intervals for your gene of interest
	grep "ref|$geneName," $agilent | awk '{print $1 "\t" $2 "\t" $3 "\t"}' | sed 's/chr//' | sort -k1,1n -k2,2n | uniq > $geneName.Agilent.intervals.bed

	## Call Diagnose Targets from GATK

	/usr/lib/jvm/jre-1.7.0/bin/java -Xmx30g -jar /opt/installed/GATK/GenomeAnalysisTK-3.5.jar \
	  -T DiagnoseTargets \
	  -R $ref \
	  -o ./$geneName.$DATE.vcf \
	  -I $bamList \
	  -L ./$geneName.Agilent.intervals.bed

    
else
    echo "Invalid arguments: 1. agilent file 2. gene name 3. list of bam files 4. path to reference"
    return