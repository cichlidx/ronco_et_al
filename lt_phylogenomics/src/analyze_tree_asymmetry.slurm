#!/bin/bash

# m_matschiner Thu May 30 14:19:56 CEST 2019

#SBATCH --job-name=treasy
#SBATCH --time=168:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=1

# Set up.
source /cluster/bin/jobsetup
module load R/3.4.4
module load ruby/2.1.5

# Get the command-line arguments.
trees=`readlink -f ${1}`
taxon2=${2}
frequency_table=`readlink -f ${3}`
ruby_script=`readlink -f analyze_tree_asymmetry_parallel.rb`
r_script=`readlink -f reroot_trees.r`

# Copy the tree file to the temporary directory.
cp ${trees} ${SCRATCH}/tmp.trees

# Change to the temporary directory.
cd ${SCRATCH}

# Reroot all trees in the tree file.
Rscript ${r_script} tmp.trees tmp_rooted.trees

# Analyze tree asymmetry.
ruby ${ruby_script} tmp_rooted.trees ${taxon2} ${frequency_table}
