#!/bin/bash

# m_matschiner Wed May 9 14:37:23 CEST 2018

# Job name:
#SBATCH --job-name=cctph
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=20G

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

## Feedback.
echo
echo "concatenate_phased_vcfs.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_dir_relative_path=${1}
gzvcf_suffix=${2}
merged_gzvcf_with_relative_path=${3}

# Concatenate all vcf files in the input directory with the given suffix.
first_vcf=true
for i in ${gzvcf_dir_relative_path}/*.${gzvcf_suffix}
do
    START=$(date +%s)
    echo -n "Reading file ${i}... "
    if [ ${first_vcf} == true ]
    then
	zcat ${i} > ${SCRATCH}/t1.vcf
	first_vcf=false
    else
	zcat ${i} | grep -v "#" >> ${SCRATCH}/t1.vcf
    fi
    print_time $START
done

# Saving the vcf file.
START=$(date +%s)
echo -n "Saving concatenated vcf as ${merged_gzvcf_with_relative_path}... "
gzip -c ${SCRATCH}/t1.vcf > ${merged_gzvcf_with_relative_path}
print_time $START
