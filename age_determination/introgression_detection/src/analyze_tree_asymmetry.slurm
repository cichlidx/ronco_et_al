#!/bin/bash

# m_matschiner Thu Dec 13 12:31:44 CET 2018

#SBATCH --job-name=asymm
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=1

# Set up.
source /cluster/bin/jobsetup
module load ruby/2.1.5

# Get the command-line arguments.
clean_tree_dir=`readlink -f ${1}`
table=`readlink -f ${2}`
ruby_script=`readlink -f analyze_tree_asymmetry.rb`

# Change to the temporary directory.
cd ${SCRATCH}

# Concatenate all trees into a single file.
cat ${clean_tree_dir}/*.tre > tmp.trees

# Analyze tree asymmetry.
ruby ${ruby_script} tmp.trees ${table}
