#!/bin/bash

# m_matschiner Tue Apr 24 12:25:02 CEST 2018

# Job name:
#SBATCH --job-name=unclsg
#
# Wall clock limit:
#SBATCH --time=1:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G

## Set up the job environment.
source /cluster/bin/jobsetup
module load bedtools/2.26.0

## Feedback.
echo
echo "get_uncallable_single.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzbed=${1}
filter=${2}
table=${3}

# Get the sample id for the first file.
sample_id=`basename ${gzbed%.${filter}.merged.bed.gz}`

# Only calculate the number of masked sites if the table file does not yet exist.
if [ ! -f ${table} ]
then
    # Calculate the total number of masked sites.
    echo -n "Calculating the number of masked sites for ${sample_id}..."
    total_masked=`zcat ${gzbed} | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}'`
    echo -e "${sample_id}\t${total_masked}" >> ${table}
    echo " done."
fi
