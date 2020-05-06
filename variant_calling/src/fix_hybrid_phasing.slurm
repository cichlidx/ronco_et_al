#!/bin/bash

# m_matschiner Thu May 3 17:48:45 CEST 2018

# Job name:
#SBATCH --job-name=fixphs
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=60G

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
module load ruby/2.1.5
module load bcftools/1.6

## Feedback.
echo
echo "fix_hybrid_phasing.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
in_gzvcf_with_relative_path=${1}
in_gzvcf_with_absolute_path=`readlink -f ${in_gzvcf_with_relative_path}`
shift
sample_table_with_relative_path=${1}
sample_table_with_absolute_path=`readlink -f ${sample_table_with_relative_path}`
shift
out_gzvcf_with_relative_path=${1}
out_gzvcf_with_absolute_path=`readlink -f ${out_gzvcf_with_relative_path}`
shift

# Feedback.
echo "Input vcf: ${in_gzvcf_with_absolute_path}"
echo "Sample table: ${sample_table_with_absolute_path}"
echo "Output vcf: ${out_gzvcf_with_absolute_path}"
echo -n "Trios: "
for trio in "$@"
do
    echo -n "${trio} "
done
echo
echo

# Make lists of species and samples.
for i in `zcat ${in_gzvcf_with_absolute_path} | head -n 1000 | grep CHROM | cut -f 10-`
do
    cat ${sample_table_with_absolute_path} | grep "^${i}"
done | cut -f 1,3 > ${SCRATCH}/samples.txt

# Copy the input files without their headers to the temporary directory.
START=$(date +%s)
echo -n "Copying the header of the unfixed vcf file to the temporary directory... "
bcftools view -h -o ${SCRATCH}/header.vcf ${in_gzvcf_with_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying the body of the unfixed vcf file to the temporary directory... "
bcftools view -H -o ${SCRATCH}/body.vcf ${in_gzvcf_with_absolute_path}
print_time $START

# Copy the ruby script to the temporary directory.
cp fix_hybrid_phasing.rb ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Mask the imputed sites.
START=$(date +%s)
echo -n "Fixing the phasing of hybrid individuals with ruby script... "
ruby fix_hybrid_phasing.rb header.vcf body.vcf body.fixed.vcf samples.txt "$@" &> out.txt
print_time $START
cat out.txt

# Combine the header of the imputed vcf and the body of the fixed vcf.
START=$(date +%s)
echo -n "Concatenating header and body of the masked vcf to ${out_gzvcf_with_absolute_path}... "
cat header.vcf body.fixed.vcf | bgzip > ${out_gzvcf_with_absolute_path} 
print_time $START
