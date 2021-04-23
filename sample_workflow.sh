#!/bin/bash

# here is an example workflow that I use to map reads and then assemble them

# copy the longs read file to your local crc space 
/afs/crc.nd.edu/user/d/dbruzzes/Public/jake

# call 24 cores to do work interactively 
qrsh -q long -pe smp 24

module load conda 
conda activate flye
# go to your directory where you want to run the analysis 

# make some variables to run the code

THREAD="24"
long="path/to/long/raw/reads"
REFERENCE="path to reference genome you are mapping to" 
DIR="directory where you are running your analysis"

# go working directory
cd $DIR

# map raw nanopore reads to reference genome
minimap2 -a -x asm5  $REFERENCE $long -t $THREAD -o mapped.sam

# drop unmapped reads 
samtools view --threads $THREAD -Sbh -F 0x4 mapped.sam | samtools sort --threads $THREAD -o sorted_mapped_wolbachia.bam

# count sumber of mapped reads
samtools view -c sorted_mapped_wolbachia.bam

# convert files to fastq 
samtools bam2fq sorted_mapped_wolbachia.bam > mapped.fastq

# assemble genome from mapped reads 
READS="mapped.fastq"

# adjust genome size for size of spiroplasma ... 
flye --nano-raw $READS --genome-size 1.5m -t $THREAD -o ./mapped 
