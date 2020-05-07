#!/bin/bash

# m_matschiner Thu Jun 14 12:14:51 CEST 2018

# Job name:
#SBATCH --job-name=raxml
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=6G

## Set up the job environment.
source /cluster/bin/jobsetup
module load python3/3.5.0
module load raxml/8.2.4

## Feedback.
echo
echo "run_raxml.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
nexus_with_relative_path=${1}
nexus_with_absolute_path=`readlink -f ${nexus_with_relative_path}`
convert_with_relative_path=${2}
convert_with_absolute_path=`readlink -f ${convert_with_relative_path}`
n_variable=${3}
n_invariable=${4}
tree_with_relative_path=${5}
tree_with_absolute_path=`readlink -f ${tree_with_relative_path}`
info_with_relative_path=${6}
info_with_absolute_path=`readlink -f ${info_with_relative_path}`
n_iterations=${7}

# Move to the temporary directory.
cd ${SCRATCH}

# Convert the input format from nexus to phylip format.
python3 ${convert_with_absolute_path} ${nexus_with_absolute_path} tmp.phy -f phylip

# Scale the number of invariable sites.
n_sites_in_alignment=`head -n 1 tmp.phy | cut -d " " -f 2`
echo "Found ${n_sites_in_alignment} sites in alignment."
(( n_invariable_scaled = ${n_invariable} * ${n_sites_in_alignment} / ${n_variable} ))
echo "The number of invariable sites was scaled from ${n_invariable} to ${n_invariable_scaled}."

# Run raxml.
raxmlHPC-PTHREADS -T 10 -s tmp.phy -n tmp -m GTRCAT -p ${RANDOM} -N ${n_iterations} --asc-corr=felsenstein ${n_invariable_scaled}

# Copy the result files to the results directory.
cp RAxML_bestTree.tmp ${tree_with_absolute_path}
cp RAxML_info.tmp ${info_with_absolute_path}
