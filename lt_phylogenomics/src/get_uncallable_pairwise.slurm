#!/bin/bash

# m_matschiner Tue Apr 24 12:25:02 CEST 2018

# Job name:
#SBATCH --job-name=unclpw
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=30G

## Set up the job environment.
source /cluster/bin/jobsetup
module load bedtools/2.26.0

## Feedback.
echo
echo "get_uncallable_pairwise.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzbed1=${1}
filter=${2}
table=${3}

# Get the sample id for the first file.
sample1=`basename ${gzbed1%.${filter}.merged.bed.gz}`

# Make pairwise comparisons.
for gzbed2 in ../data/masks/*.${filter}.merged.bed.gz
do

    # Get the sample id for the second file.
    sample2=`basename ${gzbed2%.${filter}.merged.bed.gz}`

    # Only make the comparison if the second sample comes later alphabetically.
    if [[ ${sample1} < ${sample2} ]]
    then

        # Only make the comparison if the table file does not yet exist or if the comparison is not already included in the table file.
        if [ ! -f ${table} ]
        then
             # Calculate the total number of masked sites.
            echo -n "Comparing samples ${sample1} and ${sample2}..."
            total_masked=`zcat ${gzbed1} ${gzbed2} | sort -k1,1 -k2,2n | bedtools merge | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}'`
            echo -e "${sample1}\t${sample2}\t${total_masked}" >> ${table}
            echo " done."
        else
            n_lines_with_sample2=`cat ${table} | grep ${sample2} | wc -l`
            if [[ ${n_lines_with_sample2} == 0 ]]
            then
                # Calculate the total number of masked sites.
                echo -n "Comparing samples ${sample1} and ${sample2}..."
                total_masked=`zcat ${gzbed1} ${gzbed2} | sort -k1,1 -k2,2n | bedtools merge | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}'`
                echo -e "${sample1}\t${sample2}\t${total_masked}" >> ${table}
                echo " done."
            elif [[ ${n_lines_with_sample2} == 1 ]]
            then
                echo "INFO: Skipping the comparison of samples ${sample1} and ${sample2} because it was found already in table ${table}."
            else
                echo "ERROR: Unexpectedly found ${sample2} on more than one line in the table file!"
                exit 1
            fi
        fi
    fi
done
