#!/bin/bash

# m_matschiner Wed Apr 11 16:55:00 CEST 2018

# Job name:
#SBATCH --job-name=svdq
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=61G

## Set up the job environment.
source /cluster/bin/jobsetup
module load paup/4.0a161

## Feedback.
echo
echo "run_svdquartets.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
nex_with_relative_path=${1}

# Run svdquartets.
paup ${nex_with_relative_path}
