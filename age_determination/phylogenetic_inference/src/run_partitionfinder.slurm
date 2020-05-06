#!/bin/bash

# m_matschiner Sat Nov 24 18:25:40 CET 2018

# Job name:
#SBATCH --job-name=pf
#
# Wall clock limit:
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=4G
#SBATCH --ntasks-per-node=5

## Set up the job environment.
source /cluster/bin/jobsetup
module load partitionfinder/2.1.1

## Feedback.
echo
echo "run_partitionfinder.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
dir=${1}
min_size=${2}
weight_scheme=${3}

# Run partitionfinder.
PartitionFinder.py -r -p 4 --min-subset-size ${min_size} --weights ${weight_scheme} ${dir}