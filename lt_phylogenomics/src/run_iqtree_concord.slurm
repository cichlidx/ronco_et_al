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
concat_tree=`readlink -f ${1}`
concat_tree_base=`basename ${concat_tree}`
loci_trees=`readlink -f ${2}`
loci_trees_base=`basename ${loci_trees}`
nex=`readlink -f ${3}`
nex_base=`basename ${nex}`
tree_dir=`readlink -f ${4}`
prefix=${5}

# Copy the alignment file to the temporary directory.
cp ${concat_tree} ${SCRATCH}
cp ${loci_trees} ${SCRATCH}
cp ${nex} ${SCRATCH}

# Change to the temporary directory.
cd ${SCRATCH}

# Run iqtree.
iqtree -t ${concat_tree_base} --gcf ${loci_trees_base} -s ${nex_base} -m GTR+G --scf 100 --prefix ${prefix}

# Return the result files.
cp * ${tree_dir}
