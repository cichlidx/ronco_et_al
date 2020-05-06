#!/bin/bash

# Michael Matschiner, 2016-12-02
#
# This script indexes the reference file for bwa, samtools and for 
# picard-tools. The index files are written to the same directory
# as the reference file.
#
# Start with 'sbatch prepare.slurm reference.fasta'

# Job name:
#SBATCH --job-name=prepare
#
# Wall clock limit:
#SBATCH --time=10:00:00
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
module load bwa/0.7.12
module load samtools/1.3.1
module load picard/2.6.0 # Has no effect, as picard is a jar file. Full path specified below.

## Feedback.
echo
echo "prepare.sh was called with arguments ${@}."
echo

## Get command line arguments and set variables.
ref_with_relative_path=$1
ref_with_absolute_path=`readlink -e ${ref_with_relative_path}`
ref=`basename ${ref_with_absolute_path}`
ref_absolute_path=${ref_with_absolute_path%${ref}}
ref_extension=${ref##*.}
ref_base=${ref%.$ref_extension}

## Copy input files to the work directory.
START=$(date +%s)
echo -n "Copying file ${ref}... "
cp ${ref_with_absolute_path} $SCRATCH
print_time $START

## Change to temporary directory.
cd $SCRATCH

## Index reference file for bwa.
START=$(date +%s)
echo -n "Indexing reference file for bwa... "
bwa index ${ref} &> prepare.log
echo
print_time $START

## Index reference file for samtools.
START=$(date +%s)
echo -n "Indexing reference file for samtools... "
samtools faidx ${ref}
echo
print_time $START

## Create sequence dictionary for picard-tools.
START=$(date +%s)
echo -n "Creating sequence dictionary for picard-tools... "
java -jar PATH_TO_PICARD/picard.jar CreateSequenceDictionary \
  R=${ref} \
  O=${ref%.fasta}.dict \
  URI=./${ref} &> prepare.log
echo
print_time $START

## Copy index files back to the reference directory.
START=$(date +%s)
echo -n "Copying file ${ref_base}.dict back to the reference directory... "
cp ${ref_base}.dict ${ref_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.fai back to the reference directory... "
cp ${ref}.fai ${ref_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.amb back to the reference directory... "
cp ${ref}.amb ${ref_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.ann back to the reference directory... "
cp ${ref}.ann ${ref_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.bwt back to the reference directory... "
cp ${ref}.bwt ${ref_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.pac back to the reference directory... "
cp ${ref}.pac ${ref_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.sa back to the reference directory... "
cp ${ref}.sa ${ref_absolute_path}
print_time $START

## Copy the log file back to the submission directory.
START=$(date +%s)
echo -n "Copying file prepare.log back to the submission directory... "
cp prepare.log $SUBMITDIR
print_time $START
echo
