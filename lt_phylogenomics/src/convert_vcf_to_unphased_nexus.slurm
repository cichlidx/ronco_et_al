#!/bin/bash

# m_matschiner Tue Mar 27 14:44:04 CEST 2018

# Job name:
#SBATCH --job-name=vcf2nex
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=61G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5

## Feedback.
echo
echo "convert_vcf_to_unphased_nexus.slurm called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
gzvcf=`basename ${gzvcf_with_relative_path}`
vcf=${gzvcf%.gz}
nexus_with_relative_path=${2}
nexus_with_absolute_path=`readlink -f ${nexus_with_relative_path}`
nexus=`basename ${nexus_with_absolute_path}`
samples_to_split_string=${3}

# Copy the ruby script to the temporary directory.
cp convert_vcf_to_unphased_nexus.rb ${SCRATCH}

# Change to the temporary directory.
cd ${SCRATCH}

# Uncompress the vcf file.
echo -n "Uncompressing vcf file..."
gunzip -c ${gzvcf_with_absolute_path} > ${vcf}
echo " done."

# Run a ruby script to convert the vcf to nexus format.
ruby convert_vcf_to_unphased_nexus.rb ${vcf} ${nexus} ${samples_to_split_string}

# Copying the nexus file back to the data directory.
echo -n "Copying the nexus file to ${nexus_with_relative_path}... "
cp ${nexus} ${nexus_with_absolute_path}
echo " done."