#!/bin/bash

# m_matschiner Fri Dec 14 11:14:01 CET 2018

#SBATCH --job-name=collaps
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=1

# Set up.
source /cluster/bin/jobsetup
module load R/3.4.4
module load ruby/2.1.5

# Get the command-line arguments.
tree_dir=`readlink -f ${1}`
last_char=${2}
clean_tree_dir=`readlink -f ${3}`
ruby_script=`readlink -f convert_branch_lengths_to_decimal_notation.rb`
r_script=`readlink -f collapse_short_branches.r`

# Change to the temporary directory.
cd ${SCRATCH}

# Collapse the weakly-supported nodes of all trees in the input directory.
for tree in ${tree_dir}/*${last_char}.tre
do
    # Get the tree id and the output tree name.
    tree_id=`basename ${tree%.tre}`
    clean_tree=${clean_tree_dir}/${tree_id}.tre

    # Convert all branch lengths from scientific to decimal notation.
    ruby ${ruby_script} ${tree} tmp.converted.tre

    # Collapse all nodes connected by short branch lenths.
    Rscript ${r_script} tmp.converted.tre ${clean_tree} 0.001

    # Clean up.
    rm -f tmp.converted.tre

    # Feedback.
    echo "Wrote file ${clean_tree}."
done
