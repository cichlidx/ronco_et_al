#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=stats
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=61G

## Set up the job environment.
source /cluster/bin/jobsetup
module load bcftools/1.6

## Feedback.
echo
echo "get_vcf_stats.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
vcf_with_relative_path=${1}
stats_with_relative_path=${2}

# Get stats of vcf file.
bcftools stats -s - ${vcf_with_relative_path} > ${stats_with_relative_path}
