#!/bin/bash

# m_matschiner Mon Mar 5 14:04:07 CET 2018
#
# This script uses bedtools to calculate the coverage distribution of a bam file.
#
# Start with 'sbatch get_coverage_distribution.slurm sample.bam reference.fasta.fai'

# Job name:
#SBATCH --job-name=getcov
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G

# Define a function to print the time.
function print_time {
  END=$(date +%s)
  DIFF=$(( $END - $1 ))
  dd=$(echo "$DIFF/86400" | bc)
  dt2=$(echo "$DIFF-86400*$dd" | bc)
  dh=$(echo "$dt2/3600" | bc)
  dt3=$(echo "$dt2-3600*$dh" | bc)
  dm=$(echo "$dt3/60" | bc)
  ds=$(echo "$dt3-60*$dm" | bc)
  if [ $dd -gt 0 ]; then
    echo "done in ${dd} days and ${dh} hours."
  elif [ $dh -gt 0 ]; then
    echo "done in ${dh} hours and ${dm} minutes."
  elif [ $dm -gt 0 ]; then
    echo "done in ${dm} minutes and ${ds} seconds."
  else
    echo "done in ${ds} seconds."
  fi
}

## Set up job environment
source /cluster/bin/jobsetup
module load bedtools/2.21.0

## Feedback.
echo
echo "get_coverage_distribution.slurm was called with arguments ${@}."
echo

## Get command line arguments and set variables.
bam_with_relative_path=$1
ref_with_relative_path=$2

## Run bedtools to get the coverage distribution.
START=$(date +%s)
echo -n "Calculating coverage distribution... "
bedtools genomecov -ibam ${bam_with_relative_path} -g ${ref_with_relative_path} | grep "^genome" | head -n 1000 > ${bam_with_relative_path%.bam}.covdist.txt
print_time $START
