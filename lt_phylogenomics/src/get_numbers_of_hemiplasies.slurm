#!/bin/bash

# m_matschiner Thu Oct 11 21:32:06 CEST 2018

# Job name:
#SBATCH --job-name=n_hemi
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Processor and memory usage:
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G

## Set up the job environment.
source /cluster/bin/jobsetup
module load python3/3.5.0

## Feedback.
echo
echo "get_numbers_of_hemiplasies.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
align_dir_with_relative_path=${1}
align_dir_with_absolute_path=`readlink -f ${align_dir_with_relative_path}`

# Copy scripts to the temporary directory.
cp get_number_of_hemiplasies.sh ${SCRATCH}
cp get_number_of_variable_sites.rb ${SCRATCH}
cp get_parsimony_score.sh ${SCRATCH}
cp convert.py ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Calculate the number of hemiplasies for each alignment.
for align in ${align_dir_with_absolute_path}/*[0-9].species.phy
do
    # Set the info file name.
    info_with_absolute_path=${align%.species.phy}.info.txt

    # Calculate the number of hemiplasies in this alignment.
    n_hemiplasies_calculated=`cat ${info_with_absolute_path} | grep "n_hemiplasies:" | wc -l`
    if [[ ${n_hemiplasies_calculated} == 0 ]]
    then
        python3 convert.py -f nexus ${align} tmp.alignment.nex
        n_hemiplasies=`bash get_number_of_hemiplasies.sh tmp.alignment.nex`
        echo "n_hemiplasies:${n_hemiplasies}" >> ${info_with_absolute_path}
        echo "Added hemiplasies number to file ${info_with_absolute_path}."
    fi
done

