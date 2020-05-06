#!/bin/bash

# m_matschiner Mon Mar 5 14:04:07 CET 2018
#
# This script uses a ruby script to calculate the depth per site from a gvcf file.
#
# Start with 'sbatch get_depth_from_gvcf.slurm input.gvcf'

# Job name.
#SBATCH --job-name=getdpth
#
# Wall clock limit:
#SBATCH --time=5:00:00
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

# Set up job environment
source /cluster/bin/jobsetup
module load ruby/2.1.5

# Feedback.
echo
echo "get_depth_from_gvcf.slurm was called with arguments ${@}."
echo

# Get command line arguments and set variables.
gvcfgz_with_relative_path=$1
gvcfgz_with_absolute_path=`readlink -f ${gvcfgz_with_relative_path}`
gvcfgz=`basename ${gvcfgz_with_absolute_path}`
gvcf=${gvcfgz%.gz}
dump_with_relative_path=$2
dump_with_absolute_path=`readlink -f ${dump_with_relative_path}`
dump=`basename ${dump_with_absolute_path}`

# Copy the gvcfgz file to the temporary directory.
cp ${gvcfgz_with_absolute_path} ${SCRATCH}

# Copy the ruby script to the temporary directory.
cp get_depth_from_gvcf.rb ${SCRATCH}

# Change to the temporary directory.
cd ${SCRATCH}

# Uncompress the gvcfgz file.
gunzip ${gvcfgz}

# Run the ruby script to analyse depth per site.
START=$(date +%s)
echo -n "Analysing depth per site... "
ruby get_depth_from_gvcf.rb ${gvcf} ${dump}
print_time $START

# Copy the result file back to the result directory.
START=$(date +%s)
echo -n "Copying dump file back to the result directory... "
cp ${dump} ${dump_with_absolute_path}
print_time $START