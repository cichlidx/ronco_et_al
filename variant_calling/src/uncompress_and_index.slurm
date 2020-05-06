#!/bin/bash

# Michael Matschiner, 2017-08-11
#
# This script uncompresses and indexes vcf.gz files
# generated with gzip.
#
# Start with
# 'sbatch uncompress_and_index.slurm file_name.vcf.gz chromosome_id reference.fasta'

# Job name:
#SBATCH --job-name=unc_idx
#
# Wall clock limit:
#SBATCH --time=1:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=1

## Set up the job environment
source /cluster/bin/jobsetup

## Get command line arguments.
vcfgz_file_name=$1
vcf_file_name=${vcfgz_file_name%.gz}
chromosome_id=$2
ref=$3

# Uncompress with gunzip.
gunzip -c ${vcfgz_file_name} > ${vcf_file_name}

# Create an index file with gatk. Variants are not really validated.
java -jar -Xmx2g /cluster/software/VERSIONS/gatk-3.7/GenomeAnalysisTK.jar -T ValidateVariants -R ${ref} --validateGVCF -L ${chromosome_id}:1-2 -V ${vcf_file_name}