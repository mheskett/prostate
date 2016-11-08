#!/bin/bash

# Given an agilent bait capture file, name of a gene of interest, and list of bam files
# produce visualizations on coverage using DiagnoseTargets (GATK) and python plotting

agilent = $1
geneName = $2
bamList = $3