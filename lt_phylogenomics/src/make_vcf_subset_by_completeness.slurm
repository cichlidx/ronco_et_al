#!/bin/bash

# m_matschiner Tue Mar 27 14:44:04 CEST 2018

# Job name:
#SBATCH --job-name=subcmp
#
# Wall clock limit:
#SBATCH --time=72:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=60G

## Set up the job environment.
source /cluster/bin/jobsetup
module load vcftools/0.1.14.zlib.1.2.8

## Feedback.
echo
echo "make_vcs_subset_by_completeness.slurm called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
subset_gzvcf_with_relative_path=${2}
subset_gzvcf_with_absolute_path=`readlink -f ${subset_gzvcf_with_relative_path}`
completeness=${3}

# Change to temporary directory.
cd ${SCRATCH}

# Make a vcf files with only unlinked snps.
vcftools --gzvcf ${gzvcf_with_absolute_path} --max-missing ${completeness} --recode --recode-INFO-all --out t1

# Move the output vcf file to the data directory.
gzip -c t1.recode.vcf > ${subset_gzvcf_with_absolute_path}
