#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=freqs
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=61G

## Set up the job environment.
source /cluster/bin/jobsetup
module load vcftools/0.1.14.zlib.1.2.8

## Feedback.
echo
echo "get_vcf_stats.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
vcf_with_relative_path=${1}

# Get stats of vcf file.
vcftools --gzvcf ${vcf_with_relative_path} --freq
