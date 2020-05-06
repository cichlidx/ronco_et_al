#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=mkdptm
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
echo "make_depth_mask.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
input_file_name=${1}
min_dp=${2}
max_dp=${3}

# Make a mask in bed format.
ruby make_depth_mask.rb ${input_file_name} ${min_dp} ${max_dp}

