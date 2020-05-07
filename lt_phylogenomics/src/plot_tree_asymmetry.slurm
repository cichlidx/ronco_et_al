#!/bin/bash

# m_matschiner Thu May 30 14:19:56 CEST 2019

#SBATCH --job-name=treasy
#SBATCH --time=168:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=1

# Set up.
source /cluster/bin/jobsetup
module load ruby/2.1.5

# Get the command-line arguments.
asymmetry_table=${1}
order_table=${2}
plot=${3}

# Plot tree asymmetry.
ruby plot_tree_asymmetry.rb ${asymmetry_table} ${order_table} 0.7 ${plot}

# Clean up.
rm -f ${asymmetry_table}