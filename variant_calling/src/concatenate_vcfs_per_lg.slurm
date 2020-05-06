#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=ccplg
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=20G

## Set up the job environment.
source /cluster/bin/jobsetup

## Feedback.
echo
echo "concatenate_vcfs_per_lg.slurm was called with arguments ${@}."
echo

## Get command line arguments.
lg=$1
filter=$2
ref=$3
concatenated_vcf="../res/gatk/${lg}.${filter}.vcf.gz"

## Remove the result file if it already exists.
rm -f ${concatenated_vcf}

## Make a string for all 1-mb-vcf files in correct order.
variant_string=`echo "--variant ../res/gatk/${lg}.1_1000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.1000001_2000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.2000001_3000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.3000001_4000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.4000001_5000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.5000001_6000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.6000001_7000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.7000001_8000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.8000001_9000000.${filter}.vcf.gz "`
variant_string+=`echo "--variant ../res/gatk/${lg}.9000001_10000000.${filter}.vcf.gz "`
for i in ../res/gatk/${lg}.????????_????????.${filter}.vcf.gz
do
    variant_string+=`echo "--variant ${i} "`
done
if [ ${lg} == "UNPLACED" ]
then
    variant_string+=`echo "--variant ../res/gatk/${lg}.99000001_100000000.${filter}.vcf.gz "`
    for i in ../res/gatk/${lg}.?????????_?????????.${filter}.vcf.gz
    do
        variant_string+=`echo "--variant ${i} "`
    done
fi

## Use GATKs CatVariants to concatenate vcfs per lg.
java -Xmx20g -cp PATH_TO_GATK/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants \
  -R ${ref} \
  ${variant_string} \
  -out ${concatenated_vcf} \
  --assumeSorted
