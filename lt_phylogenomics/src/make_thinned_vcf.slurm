#!/bin/bash

# m_matschiner Tue Mar 27 14:44:04 CEST 2018

# Job name:
#SBATCH --job-name=thin
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=61G

## Set up the job environment.
source /cluster/bin/jobsetup
module load vcftools/0.1.14.zlib.1.2.8

## Feedback.
echo
echo "${0} called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
thinned_gzvcf_with_relative_path=${2}
thinned_gzvcf_with_absolute_path=`readlink -f ${thinned_gzvcf_with_relative_path}`
min_snp_distance=${3}

# Change to temporary directory.
cd ${SCRATCH}

# Make a vcf files with only unlinked snps.
vcftools --gzvcf ${gzvcf_with_absolute_path} --thin ${min_snp_distance} --recode --recode-INFO-all --out t1

# Move the output vcf file to the data directory.
gzip -c t1.recode.vcf > ${thinned_gzvcf_with_absolute_path}
