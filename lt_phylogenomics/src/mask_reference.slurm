#!/bin/bash

# m_matschiner Tue Jul 17 16:17:41 CEST 2018

# Job name:
#SBATCH --job-name=mskref
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=60G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5

## Feedback.
echo
echo "mask_reference.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
script_with_relative_path=${1}
script_with_absolute_path=`readlink -f ${script_with_relative_path}`
script=`basename ${script_with_absolute_path}`
ref_with_relative_path=${2}
ref_with_absolute_path=`readlink -f ${ref_with_relative_path}`
gzmask_with_relative_path=${3}
gzmask_with_absolute_path=`readlink -f ${gzmask_with_relative_path}`
gzmask=`basename ${gzmask_with_absolute_path}`
mask=${gzmask%.gz}
masked_ref_with_relative_path=${4}
masked_ref_with_absolute_path=`readlink -f ${masked_ref_with_relative_path}`

# Copy the script file to the temporary directory.
cp ${script_with_relative_path} ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Uncompress the mask file.
echo -n "Uncompressing file ${gzmask_with_absolute_path}..."
gunzip -c ${gzmask_with_absolute_path} > ${mask}
echo " done."

# Use a ruby script to generate a masked version of the reference.
ruby ${script} ${ref_with_absolute_path} ${mask} ${masked_ref_with_absolute_path}