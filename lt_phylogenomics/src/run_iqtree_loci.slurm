#!/bin/bash

# m_matschiner Tue Dec 4 14:11:15 CET 2018

#SBATCH --job-name=iqtree
#SBATCH --time=168:00:00
#SBATCH --mem-per-cpu=20G --partition=hugemem
#SBATCH --cpus-per-task=10

# Set up.
source /cluster/bin/jobsetup
module load iqtree/1.7-beta7

# Get the command-line arguments.
nex=`readlink -f ${1}`
nex_base=`basename ${nex}`
tree_dir=`readlink -f ${2}`

# Copy the alignment file to the temporary directory.
cp ${nex} ${SCRATCH}

# Change to the temporary directory.
cd ${SCRATCH}

# Run iqtree.
iqtree -nt 10 -s ${nex_base} -S ${nex_base} -m GTR+G --prefix loci -mem 30G

# Return the result files.
cp * ${tree_dir}
