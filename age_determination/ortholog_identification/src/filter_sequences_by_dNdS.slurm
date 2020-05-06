#!/bin/bash

# m_matschiner Sun Jul 22 11:15:54 CEST 2018

# Job name:
#SBATCH --job-name=dnds
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=4G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5
module load paml/4.6

## Feedback.
echo
echo "filter_sequences_by_dNdS.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
indir=${1}
outdir=${2}
threshold=${3}

# Filter sequences by dNdS.
ruby filter_sequences_by_dNdS.rb ${indir} ${outdir} ${threshold}
