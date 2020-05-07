#!/bin/bash

# m_matschiner Wed Apr 4 17:32:03 CEST 2018

# Job name:
#SBATCH --job-name=distr
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
echo "distribute_snps.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}

# Distribute snps to a set of different files.
ruby distribute_snps.rb ${gzvcf_with_relative_path}
