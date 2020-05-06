#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=sumdpt
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5

## Feedback.
echo
echo "sum_depths.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
lg=${1}

# Sum the depth arrays over all individuals, per lg.
ruby sum_depths.rb ${lg}

