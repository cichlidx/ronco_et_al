#!/bin/bash

# m_matschiner Fri Jul 20 12:37:49 CEST 2018

# Job name:
#SBATCH --job-name=kollct
#
# Wall clock limit:
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=30G

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

## Set up the job environment.
source /cluster/bin/jobsetup
module load kollector/1.0.1

## Feedback.
echo
echo "run_kollector.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
specimen=${1}
query_w_relative_path=${2}
query_w_absolute_path=`readlink -f ${query_w_relative_path}`
query=`basename ${query_w_relative_path}`
res_w_relative_path=${3}
res_w_absolute_path=`readlink -f ${res_w_relative_path}`
log_w_relative_path=${4}
log=`basename ${log_w_relative_path}`
log_w_absolute_path=`readlink -f ${log_w_relative_path}`

# Copy the query file to the temporary directory.
START=$(date +%s)
echo -n "Copying query input files to the temporary directory... "
cp ${query_w_relative_path} ${SCRATCH}
print_time $START

# Copy fastq.gz input files to the temporary directory, concatenate them if multiple forward and reverse files exist.
START=$(date +%s)
echo -n "Copying fastq input files to the temporary directory... "
cat ../data/fastq/${specimen}_*R1.fastq.gz > ${SCRATCH}/r1.fastq.gz
cat ../data/fastq/${specimen}_*R2.fastq.gz > ${SCRATCH}/r2.fastq.gz
print_time $START

# Change to the temporary directory.
cd ${SCRATCH}

# Get the absolute paths of the concatenated input files.
r1_with_absolute_path=`readlink -f r1.fastq.gz`
r2_with_absolute_path=`readlink -f r2.fastq.gz`

# Run kollector.
START=$(date +%s)
echo -n "Running kollector... "
kollector_multiple.sh -m6 -j10 -r 0.5 -k 32 -K 20 -n 1000000 ${query} ${r1_with_absolute_path} ${r2_with_absolute_path} &> ${log_w_absolute_path}
print_time $START

# Copy results to the output directory.
cp iteration.6/kollector_assembledtargets.fa ${res_w_absolute_path}