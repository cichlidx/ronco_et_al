#!/bin/bash

# m_matschiner Wed Jun 13 09:57:18 CEST 2018

# Job name:
#SBATCH --job-name=subsmp
#
# Wall clock limit:
#SBATCH --time=72:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=60G

## Set up the job environment.
source /cluster/bin/jobsetup
module load bcftools/1.6

## Feedback.
echo
echo "make_vcs_subset_by_samples.slurm called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
subset_gzvcf_with_relative_path=${2}
subset_gzvcf_with_absolute_path=`readlink -f ${subset_gzvcf_with_relative_path}`
samples_string=${3}

# Change to temporary directory.
cd ${SCRATCH}

# Make a vcf files without the specified samples.
bcftools view -s^${samples_string} -o tmp.vcf ${gzvcf_with_absolute_path}
gzip -c tmp.vcf > ${subset_gzvcf_with_absolute_path}
