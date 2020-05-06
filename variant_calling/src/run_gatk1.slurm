#!/bin/bash

# m_matschiner Wed Apr 12 00:39:30 CEST 2017
#
# This script performs per individual variant calling with GATK's
# HaplotypeCaller.
#
# Start in parallel for each individual with
# 'sbatch run_gatk1.slurm reference.fasta XXX.merged.sorted.dedup.realn.bam XXX.gvcf'

# Job name:
#SBATCH --job-name=gatk1
#
# Wall clock limit:
#SBATCH --time=24:00:00
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

## Set up the job environment
source /cluster/bin/jobsetup
module load samtools/1.3.1
module load gatk/3.7 # Has no effect, as gatk is a jar file. Full path specified below.

## Feedback.
echo
echo "run_gatk1.slurm was called with arguments ${@}."
echo

## Get command line arguments.
ref_with_relative_path=$1
bam_with_relative_path=$2
gvcf_with_relative_path=$3
log_with_relative_path=$4
chromosome_id=$5

## Set variables based on arguments.
ref_with_absolute_path=`readlink -e ${ref_with_relative_path}`
ref=`basename ${ref_with_absolute_path}`
ref_absolute_path=${ref_with_absolute_path%${ref}}
ref_extension=${ref##*.}
ref_base=${ref%.$ref_extension}
bam_with_absolute_path=`readlink -e ${bam_with_relative_path}`
bam=`basename ${bam_with_absolute_path}`
gvcf_with_absolute_path=`readlink -f ${gvcf_with_relative_path}`
log_with_absolute_path=`readlink -f ${log_with_relative_path}`

## Copy reference files to the work directory.
START=$(date +%s)
echo -n "Copying file ${ref_base}.dict... "
cp ${ref_absolute_path}${ref_base}.dict $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}... "
cp ${ref_absolute_path}${ref} $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.amb... "
cp ${ref_absolute_path}${ref}.amb $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.ann... "
cp ${ref_absolute_path}${ref}.ann $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.bwt... "
cp ${ref_absolute_path}${ref}.bwt $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.fai... "
cp ${ref_absolute_path}${ref}.fai $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.pac... "
cp ${ref_absolute_path}${ref}.pac $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying file ${ref}.sa... "
cp ${ref_absolute_path}${ref}.sa $SCRATCH
print_time $START

## Copy input files to the work directory.
START=$(date +%s)
echo -n "Copying bam file ${bam_with_relative_path}... "
cp ${bam_with_relative_path} $SCRATCH
print_time $START
START=$(date +%s)
echo -n "Copying index file ${bam_with_relative_path}.bai... "
cp ${bam_with_relative_path}.bai $SCRATCH
print_time $START

## Change to working directory.
cd $SCRATCH

## Run GATK's HaplotypeCaller.
START=$(date +%s)
echo -n "Calling variants in bam file ${bam} with GATK's HaplotypeCaller... "
java -jar PATH_TO_GATK/GenomeAnalysisTK.jar \
  -T HaplotypeCaller \
  -R ${ref} \
  -I ${bam} \
  -L ${chromosome_id} \
  --emitRefConfidence GVCF \
  --min_base_quality_score 30 \
  --maxReadsInMemoryPerSample 10000 \
  --pcr_indel_model NONE \
  -o ${bam%.bam}.g.vcf &> run_gatk1.${bam%.merged.sorted.dedup.realn.bam}.log
print_time $START

## Compress the variant call vcf file.
START=$(date +%s)
echo -n "Compressing file ${bam%.bam}.g.vcf... "
gzip ${bam%.bam}.g.vcf
print_time $START

## Copy the compressed variant call vcf file back to the analysis directory.
START=$(date +%s)
echo -n "Copying file ${bam%.bam}.g.vcf.gz to the output directory... "
cp ${bam%.bam}.g.vcf.gz ${gvcf_with_absolute_path%.gz}.gz
print_time $START

## Copy the log file to the log directory.
START=$(date +%s)
echo -n "Copying file run_gatk1.${bam%.bam}.log back to the submission directory... "
cp run_gatk1.${bam%.merged.sorted.dedup.realn.bam}.log ${log_with_absolute_path}
print_time $START
echo
