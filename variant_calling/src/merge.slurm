#!/bin/bash

# Michael Matschiner, 2016-08-26
#
# This script merges multiple bam files for the same sample/
# individual, and performs deduplication and indel realignment
# on the merged file.
#
# Start in parallel for each individual with
# 'sbatch merge.sh reference.fasta XXX_L001.bam XXX_XXX.bam'

# Job name:
#SBATCH --job-name=merge
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=7680M

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

## Set up job environment.
source /cluster/bin/jobsetup
module load bwa/0.7.12
module load samtools/1.3.1
module load picard/2.6.0 # Has no effect, as picard is a jar file. Full path specified below.

## Feedback.
echo
echo "merge.slurm was called with arguments ${@}."
echo

## Get command line arguments.
ref_with_relative_path=$1
shift
bams_with_relative_path=()
for file in "$@"; do
  bams_with_relative_path+=(${file})
done

## Set variables based on arguments.
ref_with_absolute_path=`readlink -e ${ref_with_relative_path}`
ref=`basename ${ref_with_absolute_path}`
ref_absolute_path=${ref_with_absolute_path%${ref}}
ref_extension=${ref##*.}
ref_base=${ref%.$ref_extension}
if [ ${#bams_with_relative_path[@]} -eq 0 ]; then
  echo
  echo "ERROR: No bam files were specified in addition to the reference!"
  exit 1
elif [ ${#bams_with_relative_path[@]} -eq 1 ]; then
  echo
  echo "ERROR: Only a single bam file was specified in addition to the reference!"
  exit 1
elif [ ${#bams_with_relative_path[@]} -gt 1 ]; then
  bams_with_absolute_path=()
  bams=()
  bams_absolute_path=()
  samples=()
  file_count=0
  for file in "${bams_with_relative_path[@]}"; do
    file_count=$((file_count+1))
    bam_with_absolute_path=`readlink -e ${file}`
    bams_with_absolute_path+=(${bam_with_absolute_path})
    bam=`basename ${bam_with_absolute_path}`
    bams+=(${bam})
    bam_absolute_path=${bam_with_absolute_path%${bam}}
    bams_absolute_path+=(${bam_absolute_path})
    bam_ary=(${bam//_/ })
    sample=${bam_ary[0]}
    samples+=(${sample})
  done
  for bam_absolute_path in ${bams_absolute_path[@]:1}; do
    if [ ${bam_absolute_path} != ${bams_absolute_path[0]} ]; then
      echo
      echo "ERROR: Bam files in different directories were specified in addition to the reference!"
      exit 1
    fi
  done
  for sample in ${samples[@]:1}; do
    if [ ${sample} != ${samples[0]} ]; then
      echo
      echo "ERROR: Bam files with different sample identifiers were specified in addition to the reference!"
      exit 1
    fi
  done
fi


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
for bam in ${bams_with_relative_path[@]}; do
  START=$(date +%s)
  echo -n "Copying file ${bam}... "
  cp ${bam} $SCRATCH
  print_time $START
done

# Mark files to be returned to submitdir.
chkfile merge.${samples[0]}.log

## Change to working directory.
cd $SCRATCH

## Merging bam files with picard-tools.
START=$(date +%s)
echo -n "Merging ${file_count} bam files with picard-tools... "
input_string=`for bam in ${bams[@]} ; do echo -n "INPUT=${bam} " ; done`
java -jar PATH_TO_PICARD/picard.jar MergeSamFiles \
  $input_string \
  OUTPUT=${samples[0]}.merged.bam &> merge.${samples[0]}.log
if [ ! -f ${samples[0]}.merged.bam ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.bam does not exist."
  echo "ERROR: Something must have gone wrong with file merging."
  exit 1
fi
print_time $START

## Sorting the bam file with samtools.
START=$(date +%s)
echo -n "Sorting the bam file ${samples[0]}.merged.bam with samtools... "
samtools sort -@ 8 -m 7000M -o ${samples[0]}.merged.sorted.bam ${samples[0]}.merged.bam 2> merge.${samples[0]}.log
# samtools sort -@ 2 -m 10G ${samples[0]}.merged.bam ${samples[0]}.merged.sorted 2> merge.${samples[0]}.log
rm ${samples[0]}.merged.bam
if [ ! -f ${samples[0]}.merged.sorted.bam ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.bam does not exist."
  echo "ERROR: Something must have gone wrong with file sorting."
  exit 1
fi
print_time $START

## Marking duplicates in the bam file with picard-tools.
START=$(date +%s)
echo -n "Marking duplicates in bam ${samples[0]}.merged.sorted.bam... "
java -Xmx7g -jar PATH_TO_PICARD/picard.jar MarkDuplicates \
  MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
  I=${samples[0]}.merged.sorted.bam \
  O=${samples[0]}.merged.sorted.dedup.bam \
  M=${samples[0]}.merged.sorted.dupmetrics.txt &> merge.${samples[0]}.log
rm ${samples[0]}.merged.sorted.bam
if [ ! -f ${samples[0]}.merged.sorted.dedup.bam ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.dedup.bam does not exist."
  echo "ERROR: Something must have gone wrong with duplicate marking."
  exit 1
elif [ ! -f ${samples[0]}.merged.sorted.dupmetrics.txt ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.dupmetrics.txt does not exist."
  echo "ERROR: Something must have gone wrong with duplicate marking."
  exit 1
fi
print_time $START

## Index the bam file file samtools.
START=$(date +%s)
echo -n "Indexing bam file ${samples[0]}.merged.sorted.dedup.bam with samtools... "
samtools index ${samples[0]}.merged.sorted.dedup.bam > merge.${samples[0]}.log
print_time $START

## Running GATK's RealignerTargetCreator as a first step to realign indels.
START=$(date +%s)
echo -n "Creating realignment targets for bam file ${samples[0]}.merged.sorted.dedup.bam with GATK... "
java -jar PATH_TO_GATK/GenomeAnalysisTK.jar \
  -T RealignerTargetCreator \
  -R ${ref} \
  -I ${samples[0]}.merged.sorted.dedup.bam \
  -o ${samples[0]}.merged.sorted.dedup.bam.intervals \
  --validation_strictness STRICT &> merge.${samples[0]}.log
if [ ! -f ${samples[0]}.merged.sorted.dedup.bam.intervals ]; then
  cp merge.${samples[0]}.log $SUBMITDIR
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.dedup.bam.intervals does not exist."
  echo "ERROR: Something must have gone wrong with realignment target creation."
  exit 1
fi
print_time $START

## Running GATK's IndelRealigner as a second step to realign indels.
START=$(date +%s)
echo -n "Realigning indels in bam file ${samples[0]}.merged.sorted.dedup.bam with GATK... "
java -jar PATH_TO_GATK/GenomeAnalysisTK.jar \
  -T IndelRealigner \
  -R ${ref} \
  -I ${samples[0]}.merged.sorted.dedup.bam \
  -targetIntervals ${samples[0]}.merged.sorted.dedup.bam.intervals \
  -o ${samples[0]}.merged.sorted.dedup.realn.bam &> merge.${samples[0]}.log
rm ${samples[0]}.merged.sorted.dedup.bam
if [ ! -f ${samples[0]}.merged.sorted.dedup.realn.bam ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.dedup.realn.bam does not exist."
  echo "ERROR: Something must have gone wrong with indel realignment."
  exit 1
fi
print_time $START

## Validate the bam file with picard-tools.
echo -n "Validating bam file ${samples[0]}.merged.sorted.dedup.realn.bam... "
java -Xmx7g -jar PATH_TO_PICARD/picard.jar ValidateSamFile \
  MAX_OPEN_TEMP_FILES=1000 \
  I=${samples[0]}.merged.sorted.dedup.realn.bam \
  O=${samples[0]}.merged.sorted.dedup.realn.valid &> merge.${samples[0]}.log
if [ ! -f ${samples[0]}.merged.sorted.dedup.realn.valid ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.dedup.realn.valid does not exist."
  echo "ERROR: Something must have gone wrong with bam file validation."
  exit 1
elif [ "$(cat ${samples[0]}.merged.sorted.dedup.realn.valid)" != "No errors found" ]; then
  echo
  echo "ERROR: File ${samples[0]}.merged.sorted.dedup.realn.bam is not valid:"
  echo "$(cat ${samples[0]}.merged.sorted.dedup.realn.valid)"
  exit 1
fi
print_time $START

## Index the bam file file samtools.
START=$(date +%s)
echo -n "Indexing bam file ${samples[0]}.merged.sorted.dedup.realn.bam with samtools... "
samtools index ${samples[0]}.merged.sorted.dedup.realn.bam > merge.${samples[0]}.log
print_time $START

## Copying the bam file, its index file, and the dupmetrics file back to the analysis directory.
START=$(date +%s)
echo -n "Copying file ${samples[0]}.merged.sorted.dedup.realn.bam back to the analysis directory... "
cp ${samples[0]}.merged.sorted.dedup.realn.bam ${bam_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${samples[0]}.merged.sorted.dedup.realn.bam.bai back to the analysis directory... "
cp ${samples[0]}.merged.sorted.dedup.realn.bam.bai ${bam_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${samples[0]}.merged.sorted.dupmetrics.txt to the analysis directory... "
cp ${samples[0]}.merged.sorted.dupmetrics.txt ${bam_absolute_path}
print_time $START
