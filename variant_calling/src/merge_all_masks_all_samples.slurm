#!/bin/bash

# m_matschiner Mon Jun 18 17:51:12 CEST 2018

# Job name:
#SBATCH --job-name=mrgbed
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G

## Set up the job environment.
source /cluster/bin/jobsetup
module load bedtools/2.26.0

## Feedback.
echo
echo "merge_all_masks_all_samples.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
depth_mask_with_relative_path=${1}
indel_mask_with_relative_path=${2}
mappability_mask_with_relative_path=${3}
merged_gzbed_with_relative_path=${4}
merged_gzbed_with_absolute_path=`readlink -f ${merged_gzbed_with_relative_path}`

# Concatenate the mask files into one unsorted mask file.
echo -n "Concatenating all mask files..."
cat ${depth_mask_with_relative_path} | tail -n +2 > ${SCRATCH}/unsorted.bed
cat ${indel_mask_with_relative_path} | tail -n +2 >> ${SCRATCH}/unsorted.bed
cat ${mappability_mask_with_relative_path} | grep -v NC_013663 >> ${SCRATCH}/unsorted.bed
echo " done."

# Move to the temporary directory.
cd ${SCRATCH}

# Generate one sorted mask file.
echo -n "Sorting the unsorted mask file..."
sort -k1,1 -k2,2n unsorted.bed > sorted.bed
echo " done."

# Generate one merged mask file.
echo -n "Merging the sorted mask file..."
bedtools merge -i sorted.bed > merged.bed
echo " done."

# Return the merged mask file to the result directory.
echo -n "Returning the merged mask file to ${merged_gzbed_with_absolute_path}..."
cat merged.bed | gzip > ${merged_gzbed_with_absolute_path}
echo " done."
