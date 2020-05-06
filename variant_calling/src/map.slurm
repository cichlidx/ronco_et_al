#!/bin/bash

# Michael Matschiner, 2016-08-26
#
# This script maps resequencing data in fastq.gz format against
# a reference genome. The first argument must be the reference
# file, followed by one or two fastq.gz files. Names of fastq.gz
# files are expected to be in format SAMPLE_LIBRARY_REP.fastq.gz,
# where 'SAMPLE' should be the identifier of the sample/individual,
# 'LIBRARY' should be the identifier of the sequencing library, and 'REP'
# should bei either R1 or R2. If two fastq.gz
# files are specified, both files should have the same sample and 
# library identifiers, but the replicate identifier should differ.
# The second file is assumed to contain mate pair data for the first
# file. Before running this script, the reference file should be
# indexed with script prepare.sh.
#
# Start in parallel for each individual with
# 'sbatch -o out.txt map.slurm reference.fasta adapters.fasta output_dir XXX_XXX_R1.fastq.gz XXX_XXX_R2.fastq.gz'

# Job name:
#SBATCH --job-name=map
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Processor and memory usage:
#SBATCH --nodes=1 --exclusive
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=3840M

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

## Feedback.
echo
echo "map.slurm was called with arguments ${@}."
echo

## Get command line arguments.
ref_with_relative_path=$1
shift
adapter_file_with_relative_path=$1
shift
output_dir_relative_path=$1
shift
fastqs_with_relative_path=()
for file in "$@"; do
  fastqs_with_relative_path+=(${file})
done

## Set variables based on arguments.
ref_with_absolute_path=`readlink -e ${ref_with_relative_path}`
ref=`basename ${ref_with_absolute_path}`
ref_absolute_path=${ref_with_absolute_path%${ref}}
ref_extension=${ref##*.}
ref_base=${ref%.$ref_extension}
adapter_file_with_absolute_path=`readlink -e ${adapter_file_with_relative_path}`
adapter_file=`basename ${adapter_file_with_absolute_path}`
output_dir_absolute_path=`readlink -e ${output_dir_relative_path}`
mate_pairs='false'
if [ ${#fastqs_with_relative_path[@]} -eq 0 ]; then
  echo
  echo "ERROR: No sequence files were specified in addition to the reference!"
  exit 1
elif [ ${#fastqs_with_relative_path[@]} -eq 1 ]; then
  fastq0_with_absolute_path=`readlink -e ${fastqs_with_relative_path[0]}`
  fastq0=`basename ${fastq0_with_absolute_path}`
  fastq0_absolute_path=${fastq0_with_absolute_path%${fastq0}}
  fastq0_ary=(${fastq0//_/ })
  sample0=${fastq0_ary[0]}
  library0=${fastq0_ary[1]}
  rep0_string=${fastq0_ary[2]}
  rep0_ary=(${rep0_string//./ })
  rep0=${rep0_ary[0]}
elif [ ${#fastqs_with_relative_path[@]} -eq 2 ]; then
  mate_pairs='true'
  fastq0_with_absolute_path=`readlink -e ${fastqs_with_relative_path[0]}`
  fastq0=`basename ${fastq0_with_absolute_path}`
  fastq0_absolute_path=${fastq0_with_absolute_path%${fastq0}}
  fastq0_ary=(${fastq0//_/ })
  sample0=${fastq0_ary[0]}
  library0=${fastq0_ary[1]}
  rep0_string=${fastq0_ary[2]}
  rep0_ary=(${rep0_string//./ })
  rep0=${rep0_ary[0]}
  fastq1_with_absolute_path=`readlink -e ${fastqs_with_relative_path[1]}`
  fastq1=`basename ${fastq1_with_absolute_path}`
  fastq1_absolute_path=${fastq1_with_absolute_path%${fastq1}}
  fastq1_ary=(${fastq1//_/ })
  sample1=${fastq1_ary[0]}
  library1=${fastq1_ary[1]}
  rep1_string=${fastq1_ary[2]}
  rep1_ary=(${rep1_string//./ })
  rep1=${rep1_ary[0]}
  if [ ${fastq0_absolute_path} != ${fastq1_absolute_path} ]; then
    echo
    echo "ERROR: Two sequence files in different directories were specified in addition to the reference!"
    exit 1
  elif [ ${sample0} != ${sample1} ]; then
    echo
    echo "ERROR: Two sequence files with different sample identifiers were specified in addition to the reference!"
    exit 1
  elif [ ${library0} != ${library1} ]; then
    echo
    echo "ERROR: Two sequence files with different library identifiers were specified in addition to the reference!"
    exit 1
  elif [ ${rep0} == ${rep1} ]; then
    echo
    echo "ERROR: Two sequence files with identical replicate identifiers were specified in addition to the reference!"
    exit 1
  fi
elif [ ${#fastqs_with_relative_path[@]} -gt 2 ]; then
  echo
  echo "ERROR: More than two sequence files were specified in addition to the reference!"
  exit 1
fi
analysis_dir_absolute_path=${fastq0_absolute_path}

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
START=$(date +%s)
echo -n "Copying file ${adapter_file}... "
cp ${adapter_file_with_absolute_path} $SCRATCH
print_time $START

## Copy input files to the work directory.
for fastq in "${fastqs_with_relative_path[@]}"; do
  START=$(date +%s)
  echo -n "Copying file ${fastq}... "
  cp ${fastq} $SCRATCH
  print_time $START
done

## Change to working directory.
cd $SCRATCH

## Remove adapters.
START=$(date +%s)
echo -n "Removing adapters with Trimmomatic... "
if [ $mate_pairs == 'true' ]; then
  java -jar PATH_TO_TRIMMOMATIC/trimmomatic-0.36.jar PE -threads 16 \
  ${fastq0} ${fastq1} \
  tmp_for_paired.fq.gz tmp_for_single.fq.gz tmp_rev_paired.fq.gz tmp_rev_unpaired.fq.gz \
  ILLUMINACLIP:${adapter_file}:2:30:12:8:true MINLEN:30 &> map.${sample0}_${library0}.log
else
  java -jar PATH_TO_TRIMMOMATIC/trimmomatic-0.36.jar SE -threads 16 \
  ${fastq0} \
  tmp.fq.gz \
  ILLUMINACLIP:${adapter_file}:2:30:12:8:true MINLEN:30 &> map.${sample0}_${library0}.log
fi
print_time $START

## Map against the reference with bwa mem.
START=$(date +%s)
echo -n "Mapping against reference ${ref} with bwa mem... "
if [ $mate_pairs == 'true' ]; then
  bwa mem -t 16 -M -R "@RG\tID:${sample0}_${library0}\tSM:${sample0}_${library0}_${rep0}_${rep1}" ${ref} tmp_for_paired.fq.gz tmp_rev_paired.fq.gz > tmp.sam 2> map.${sample0}_${library0}.log
else
  bwa mem -t 16 -M -R "@RG\tID:${sample0}_${library0}\tSM:${sample0}_${library0}_${rep0}" ${ref} tmp.fq.gz > tmp.sam 2> map.${sample0}_${library0}.log
fi
print_time $START

## Converting sam to bam format with samtools.
START=$(date +%s)
echo -n "Converting sam to bam format with samtools... "
samtools view -hbS tmp.sam > ${sample0}_${library0}.bam
rm tmp.sam
if [ ! -f ${sample0}_${library0}.bam ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.sorted.bam does not exist."
  echo "ERROR: Something must have gone wrong with mapping."
  exit 1
fi
print_time $START

## Sort the bam file with samtools.
START=$(date +%s)
echo -n "Sorting the bam file ${sample0}_${library0}.bam with samtools... "
samtools sort -@ 16 -m 3500M -o ${sample0}_${library0}.sorted.bam ${sample0}_${library0}.bam
rm ${sample0}_${library0}.bam
if [ ! -f ${sample0}_${library0}.sorted.bam ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.sorted.bam does not exist."
  echo "ERROR: Something must have gone wrong with file sorting."
  exit 1
fi
print_time $START

## Mark duplicates in the bam file with picard-tools.
START=$(date +%s)
echo -n "Marking duplicates in bam file ${sample0}_${library0}.sorted.bam... "
java -jar PATH_TO_PICARD/picard.jar MarkDuplicates \
  MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
  I=${sample0}_${library0}.sorted.bam \
  O=${sample0}_${library0}.sorted.dedup.bam \
  M=${sample0}_${library0}.dupmetrics.txt &> map.${sample0}_${library0}.log
rm ${sample0}_${library0}.sorted.bam
if [ ! -f ${sample0}_${library0}.sorted.dedup.bam ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.sorted.dedup.bam does not exist."
  echo "ERROR: Something must have gone wrong with duplicate marking."
  exit 1
elif [ ! -f ${sample0}_${library0}.dupmetrics.txt ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.dupmetrics.txt does not exist."
  echo "ERROR: Something must have gone wrong with duplicate marking."
  exit 1
fi
print_time $START

## Index the bam file file samtools.
START=$(date +%s)
echo -n "Indexing bam file ${sample0}_${library0}.sorted.dedup.bam with samtools... "
samtools index ${sample0}_${library0}.sorted.dedup.bam
print_time $START

## Run GATK's RealignerTargetCreator as a first step to realign indels.
START=$(date +%s)
echo -n "Creating realignment targets for bam file ${sample0}_${library0}.sorted.dedup.bam with GATK... "
java -jar PATH_TO_GATK/GenomeAnalysisTK.jar \
  -T RealignerTargetCreator \
  -R ${ref} \
  -I ${sample0}_${library0}.sorted.dedup.bam \
  -o ${sample0}_${library0}.sorted.dedup.bam.intervals \
  --validation_strictness STRICT &> map.${sample0}_${library0}.log
if [ ! -f ${sample0}_${library0}.sorted.dedup.bam.intervals ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.sorted.dedup.bam.intervals does not exist."
  echo "ERROR: Something must have gone wrong with realignment target creation."
  exit 1
fi
print_time $START

## Run GATK's IndelRealigner as a second step to realign indels.
START=$(date +%s)
echo -n "Realigning indels in bam file ${sample0}_${library0}.sorted.dedup.bam with GATK... "
java -jar PATH_TO_GATK/GenomeAnalysisTK.jar \
  -T IndelRealigner \
  -R ${ref} \
  -I ${sample0}_${library0}.sorted.dedup.bam \
  -targetIntervals ${sample0}_${library0}.sorted.dedup.bam.intervals \
  -o ${sample0}_${library0}.sorted.dedup.realn.bam &> map.${sample0}_${library0}.log
rm ${sample0}_${library0}.sorted.dedup.bam
if [ ! -f ${sample0}_${library0}.sorted.dedup.realn.bam ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.sorted.dedup.realn.bam does not exist."
  echo "ERROR: Something must have gone wrong with indel realignment."
  exit 1
fi
print_time $START

## Add read groups.
START=$(date +%s)
echo -n "Adding read groups with picard-tools... "
java -jar PATH_TO_PICARD/picard.jar AddOrReplaceReadGroups \
  I=${sample0}_${library0}.sorted.dedup.realn.bam \
  O=${sample0}_${library0}.sorted.dedup.realn.rgadd.bam \
  RGID=${sample0}_${library0} \
  RGLB=${library0} \
  RGPL=illumina \
  RGPU=${library0} \
  RGSM=${sample0} \
  VALIDATION_STRINGENCY=LENIENT &> map.${sample0}_${library0}.log
if [ ! -f ${sample0}_${library0}.sorted.dedup.realn.rgadd.bam ]; then
  echo
  echo "ERROR: File ${sample0}_${library0}.sorted.dedup.realn.rgadd.bam does not exist."
  echo "ERROR: Something must have gone wrong with read group adding."
  exit 1
fi
print_time $START

## Index the bam file file samtools.
START=$(date +%s)
echo -n "Indexing bam file ${sample0}_${library0}.sorted.dedup.realn.rgadd.bam with samtools... "
samtools index ${sample0}_${library0}.sorted.dedup.realn.rgadd.bam
print_time $START

## Copy the bam file and the dupmetrics file to the output directory.
START=$(date +%s)
echo -n "Copying file ${sample0}_${library0}.bam to the output directory... "
cp ${sample0}_${library0}.sorted.dedup.realn.rgadd.bam ${output_dir_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${sample0}_${library0}.bam.bai to the output directory... "
cp ${sample0}_${library0}.sorted.dedup.realn.rgadd.bam.bai ${output_dir_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${sample0}_${library0}.dupmetrics.txt to the output directory... "
cp ${sample0}_${library0}.dupmetrics.txt ${output_dir_absolute_path}
print_time $START

## Copy the log file to the output directory.
START=$(date +%s)
echo -n "Copying file map.${sample0}_${library0}.log to the submission directory... "
cp map.${sample0}_${library0}.log ${output_dir_absolute_path}
print_time $START
echo
