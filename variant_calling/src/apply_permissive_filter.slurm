#!/bin/bash

# m_matschiner Fri Sep 1 17:09:12 CEST 2017

# Job name:
#SBATCH --job-name=flt5
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=1G

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
module load bcftools/1.6
module load vcftools/0.1.14.zlib.1.2.8
module load ruby/2.1.5

## Feedback.
echo
echo "apply_permissive_filter.slurm was called with arguments ${@}."
echo

## Get command line arguments.
vcfgz_with_relative_path=${1}
vcfgzcsi_with_relative_path="${vcfgz_with_relative_path}.csi"
ref_with_relative_path=${2}
mappability_bed_with_relative_path=${3}
filtered_vcfgz_with_relative_path=${4}
indel_bed_with_relative_path="${filtered_vcfgz_with_relative_path%.vcf.gz}.indels.bed"
log_with_relative_path=${5}
missingness_before_with_relative_path="${filtered_vcfgz_with_relative_path%.vcf.gz}.missing_before.txt"
missingness_before_with_absolute_path=`readlink -f ${missingness_before_with_relative_path}`
missingness_after_with_relative_path="${filtered_vcfgz_with_relative_path%.vcf.gz}.missing_after.txt"
missingness_after_with_absolute_path=`readlink -f ${missingness_after_with_relative_path}`

## Make sure the input file and its index file exist.
if [ ! -f ${vcfgz_with_relative_path} ]
then
  echo
  echo "ERROR: The file ${vcfgz_with_relative_path} does not exist!"
  exit 1
fi
if [ ! -f ${vcfgzcsi_with_relative_path} ]
then
  START=$(date +%s)
  echo -n "Indexing file ${vcfgz_with_relative_path}... "
  bcftools index ${vcfgz_with_relative_path}
  if [ ! -f ${vcfgzcsi_with_relative_path} ]
  then
    echo
    echo "ERROR: The file ${vcfgzcsi_with_relative_path} does not exist!"
    echo "ERROR: Something must have gone wrong with indexing."
    exit 1
  fi
  print_time $START
fi

## Get the absolute file paths.
vcfgz=`basename ${vcfgz_with_relative_path}`
vcfgz_with_absolute_path=`readlink -e ${vcfgz_with_relative_path}`
vcfgzcsi=`basename ${vcfgzcsi_with_relative_path}`
vcfgzcsi_with_absolute_path=`readlink -e ${vcfgzcsi_with_relative_path}`
ref_with_absolute_path=`readlink -e ${ref_with_relative_path}`
mappability_bed=`basename ${mappability_bed_with_relative_path}`
filtered_vcfgz=`basename ${filtered_vcfgz_with_relative_path}`
filtered_vcfgz_with_absolute_path=`readlink -f ${filtered_vcfgz_with_relative_path}`
indel_bed=`basename ${indel_bed_with_relative_path}`
indel_bed_with_absolute_path=`readlink -f ${indel_bed_with_relative_path}`
log=`basename ${log_with_relative_path}`
log_with_absolute_path=`readlink -f ${log_with_relative_path}`

## Exit if the output file exists already.
if [ -f ${filtered_vcfgz_with_absolute_path} ]
then
  echo
  echo "ERROR: The output file ${filtered_vcfgz_with_absolute_path} exists already."
  exit 1
fi

## Remove the log file if it exists already.
rm -f ${log_with_relative_path}

## Interpreting file names for minimum and maximum positions.
vcfgz_ary=(${vcfgz//./ })
linkage_group=${vcfgz_ary[0]}
range=${vcfgz_ary[1]}
range_ary=(${range//_/ })
minimum=${range_ary[0]}
maximum=${range_ary[1]}
echo "Assuming that file ${vcfgz} includes sites between positions ${minimum} and ${maximum} on linkage group ${linkage_group}."

## Copy ruby scripts to the temporary directory.
cp make_indel_mask.rb $SCRATCH
cp replace_spanning_deletions.rb $SCRATCH

## Copy the mappability mask to the temporary directory.
echo -e "chrom\tchromStart\tchromEnd" > $SCRATCH/${mappability_bed}
cat ${mappability_bed_with_relative_path} >> $SCRATCH/${mappability_bed}

## Touch the index file to turn off the bcftools warning that it is older.
touch ${vcfgzcsi_with_absolute_path}

## Change to the temporary directory.
cd $SCRATCH

## Removing sites with low quality with bcftools (1/2).
START=$(date +%s)
echo -n "Removing sites with low quality (1/2)... "
bcftools filter -i 'FS<20.0 && QD>2.0 && MQ>20.0 && DP>4000 && DP<8000 && InbreedingCoeff>-0.5' -o t1.vcf ${vcfgz_with_absolute_path} &> ${log_with_absolute_path}
if [ ! -f t1.vcf ]; then
  echo
  echo "ERROR: File t1.vcf does not exist."
  echo "ERROR: Something must have gone wrong with filtering for quality (1/2)."
  exit 1
fi
length_t0=`bcftools view -H ${vcfgz_with_absolute_path} | wc -l`
length_t1=`bcftools view -H t1.vcf | wc -l`
print_time $START
echo "-> Removed $(( ${length_t0} - ${length_t1} )) sites (before: ${length_t0}, after: ${length_t1})."

## Removing sites with low quality with bcftools (2/2).
START=$(date +%s)
echo -n "Removing sites with low quality (2/2)... "
bcftools filter -e 'ReadPosRankSum<-0.5 || MQRankSum<-0.5' -o t2.vcf t1.vcf &> ${log_with_absolute_path}
if [ ! -f t2.vcf ]; then
  echo
  echo "ERROR: File t2.vcf does not exist."
  echo "ERROR: Something must have gone wrong with filtering for quality (2/2)."
  exit 1
fi
length_t2=`bcftools view -H t2.vcf | wc -l`
rm t1.vcf
print_time $START
echo "-> Removed $(( ${length_t1} - ${length_t2} )) sites (before: ${length_t1}, after: ${length_t2})."

## Remove Oreochromini, Coptodini, and Pelmatolapiini.
START=$(date +%s)
echo -n "Removing Oreochromini, Coptodini, and Pelmatolapiini... "
bcftools view -s ^JAB6,JAC7,KYH4,Z03,Z07,Z09,Z17,JWE6,JWF2 -a --min-ac=1 -o t3.vcf t2.vcf &> ${log_with_absolute_path}
if [ ! -f t3.vcf ]; then
  echo
  echo "ERROR: File t3.vcf does not exist."
  echo "ERROR: Something must have gone wrong with removing outgroups."
  exit 1
fi
length_t3=`bcftools view -H t3.vcf | wc -l`
rm t2.vcf
print_time $START
echo "-> Removed $(( ${length_t2} - ${length_t3} )) sites (before: ${length_t2}, after: ${length_t3})."

## Normalize indels.
START=$(date +%s)
echo -n "Normalizing indels... "
bcftools norm -f ${ref_with_absolute_path} -o t4.vcf t3.vcf &> ${log_with_absolute_path}
if [ ! -f t4.vcf ]; then
  echo
  echo "ERROR: File t4.vcf does not exist."
  echo "ERROR: Something must have gone wrong with indel normalization."
  exit 1
fi
rm t3.vcf
print_time $START

## Remove those sites where all samples have the alternate allele.
START=$(date +%s)
echo -n "Removing all sites without reference alleles... "
bcftools view -e 'AC==AN' -o t5.vcf t4.vcf &> ${log_with_absolute_path}
if [ ! -f t5.vcf ]; then
  echo
  echo "ERROR: File t5.vcf does not exist."
  echo "ERROR: Something must have gone wrong with removal of sites without reference alleles."
  exit 1
fi
length_t4=`bcftools view -H t4.vcf | wc -l`
length_t5=`bcftools view -H t5.vcf | wc -l`
rm t4.vcf
print_time $START
echo "-> Removed $(( ${length_t4} - ${length_t5} )) sites (before: ${length_t4}, after: ${length_t5})."

## Separate SNP-only and indel sites.
START=$(date +%s)
echo -n "Separating SNP-only and indel sites... "
bcftools view -i 'TYPE="snp"' -o t5.snps.vcf t5.vcf
bcftools view -i 'TYPE~"indel"' -o t5.indels.vcf t5.vcf
if [ ! -f t5.snps.vcf ]; then
  echo
  echo "ERROR: File t5.snps.vcf does not exist."
  echo "ERROR: Something must have gone wrong with extracting SNP-only sites."
  exit 1
fi
if [ ! -f t5.indels.vcf ]; then
  echo
  echo "ERROR: File t5.indels.vcf does not exist."
  echo "ERROR: Something must have gone wrong with extracting indel sites."
  exit 1
fi
print_time $START

## Remove indel sites with minor allele count of 2 or less. 
START=$(date +%s)
echo -n "Removing all indel sites without reference alleles... "
bcftools view --min-ac=2 -o t6.indels.vcf t5.indels.vcf &> ${log_with_absolute_path}
if [ ! -f t6.indels.vcf ]; then
  echo
  echo "ERROR: File t6.indels.vcf does not exist."
  echo "ERROR: Something must have gone wrong with removing indel sites with low minor allele count."
  exit 1
fi
length_t5i=`bcftools view -H t5.indels.vcf | wc -l`
length_t6i=`bcftools view -H t6.indels.vcf | wc -l`
rm t5.indels.vcf
print_time $START
echo "-> Removed $(( ${length_t5i} - ${length_t6i} )) indels (before: ${length_t5i}, after: ${length_t6i})."

## Convert the indel vcf file into a list of indels.
START=$(date +%s)
echo -n "Converting the indel vcf file into a list... "
bcftools view -H t6.indels.vcf | cut -f 1,2,4,5 > t6.indels.txt
if [ ! -f t6.indels.txt ]; then
  echo
  echo "ERROR: File t6.indels.txt does not exist."
  echo "ERROR: Something must have gone wrong with conversion of the indel file.."
  exit 1
fi
rm t6.indels.vcf
print_time $START

## Make a mask for sites in proximity to indels.
START=$(date +%s)
echo -n "Making a mask for sites in proximity to indels... "
feedback=`ruby make_indel_mask.rb t6.indels.txt ${indel_bed} ${minimum} ${maximum}`
if [ ! -f ${indel_bed} ]; then
  echo
  echo "ERROR: File ${indel_bed} does not exist."
  echo "ERROR: Something must have gone wrong with making a mask for sites in proximity to indels."
  exit 1
fi
print_time $START
echo "-> ${feedback}"

## Apply the mask for sites in proximity to indels.
START=$(date +%s)
echo -n "Applying the mask for sites in proximity to indels... "
vcftools --vcf t5.snps.vcf --exclude-bed ${indel_bed} --recode --recode-INFO-all --out t6 2> ${log_with_absolute_path}
if [ ! -f t6.recode.vcf ]; then
  echo
  echo "ERROR: File t6.recode.vcf does not exist."
  echo "ERROR: Something must have gone wrong with applying the mask for sites in proximity to indels."
  exit 1
fi
length_t5s=`bcftools view -H t5.snps.vcf | wc -l`
length_t6=`bcftools view -H t6.recode.vcf | wc -l`
rm t5.snps.vcf
print_time $START
mv t6.recode.vcf t6.vcf
echo "-> Removed $(( ${length_t5s} - ${length_t6} )) sites (before: ${length_t5s}, after: ${length_t6})."

## Apply the mask for mappable sites.
START=$(date +%s)
echo -n "Applying the mask for mappable sites... "
vcftools --vcf t6.vcf --exclude-bed ${mappability_bed} --recode --recode-INFO-all --out t7 2> ${log_with_absolute_path}
if [ ! -f t7.recode.vcf ]; then
  echo
  echo "ERROR: File t7.recode.vcf does not exist."
  echo "ERROR: Something must have gone wrong with applying the mask for mappable sites."
  exit 1
fi
length_t7=`bcftools view -H t7.recode.vcf | wc -l`
rm t6.vcf
print_time $START
echo "-> Removed $(( ${length_t6} - ${length_t7} )) sites (before: ${length_t6}, after: ${length_t7})."
mv t7.recode.vcf t7.vcf

## Replace alleles coding for spanning deletions with missing data.
START=$(date +%s)
echo -n "Replace alleles coding for spanning deletions... "
ruby replace_spanning_deletions.rb t7.vcf t8.vcf
if [ ! -f t8.vcf ]; then
  echo
  echo "ERROR: File t8.vcf does not exist."
  echo "ERROR: Something must have gone wrong with replacing spanning deletions."
  exit 1
fi
rm t7.vcf
print_time $START

## Filter for depth.
START=$(date +%s)
echo -n "Filtering for depth per individual... "
vcftools --vcf t8.vcf --minDP 4 --recode --recode-INFO-all --out t9 2> ${log_with_absolute_path}
if [ ! -f t9.recode.vcf ]; then
  echo
  echo "ERROR: File t9.recode.vcf does not exist."
  echo "ERROR: Something must have gone wrong with filtering for quality and depth."
  exit 1
fi
rm t8.vcf
print_time $START
mv t9.recode.vcf t9.vcf

## Calculate missingness per individual.
START=$(date +%s)
echo -n "Calculating missingness per individual... "
vcftools --vcf t9.vcf --missing-indv 2> ${log_with_absolute_path}
if [ ! -f out.imiss ]; then
  echo
  echo "ERROR: File out.imiss does not exist."
  echo "ERROR: Something must have gone wrong with calculating missingness per individual."
  exit 1
fi
print_time $START
cp out.imiss ${missingness_before_with_absolute_path}
rm -f out.imiss

## Filter for quality.
START=$(date +%s)
echo -n "Filtering for quality per individual... "
vcftools --vcf t9.vcf --minGQ 20 --recode --recode-INFO-all --out t10 2> ${log_with_absolute_path}
if [ ! -f t10.recode.vcf ]; then
  echo
  echo "ERROR: File t10.recode.vcf does not exist."
  echo "ERROR: Something must have gone wrong with filtering for quality and depth."
  exit 1
fi
rm t9.vcf
print_time $START
mv t10.recode.vcf t10.vcf

## Calculate missingness per individual.
START=$(date +%s)
echo -n "Calculating missingness per individual... "
vcftools --vcf t10.vcf --missing-indv 2> ${log_with_absolute_path}
if [ ! -f out.imiss ]; then
  echo
  echo "ERROR: File out.imiss does not exist."
  echo "ERROR: Something must have gone wrong with calculating missingness per individual."
  exit 1
fi
print_time $START
cp out.imiss ${missingness_after_with_absolute_path}
rm -f out.imiss

## Remove alternative alleles that are no longer observed.
START=$(date +%s)
echo -n "Removing alternative alleles that are no longer observed... "
bcftools view -a --min-ac=1 -o t11.vcf t10.vcf &> ${log_with_absolute_path}
if [ ! -f t11.vcf ]; then
  echo
  echo "ERROR: File t11.vcf does not exist."
  echo "ERROR: Something must have gone wrong with removing alternative alleles."
  exit 1
fi
length_t11=`bcftools view -H t11.vcf | wc -l`
rm t10.vcf
print_time $START
echo "-> Removed $(( ${length_t11} - ${length_t7} )) sites (before: ${length_t7}, after: ${length_t11})."

## Recalculate the AN and AC info fields.
START=$(date +%s)
echo -n "Recalculating info fields... "
cat t11.vcf | fill-an-ac > t12.vcf
if [ ! -f t12.vcf ]; then
  echo
  echo "ERROR: File t12.vcf does not exist."
  echo "ERROR: Something must have gone wrong with recalculating info fields."
  exit 1
fi
length_t12=`bcftools view -H t12.vcf | wc -l`
rm t11.vcf
print_time $START
if [ $length_t12 != $length_t11 ]; then
  echo
  echo "ERROR: The number of sites differs between files t11.vcf and t12.vcf (t11.vcf: ${length_t11}; t12.vcf: ${length_t12})."
  exit 1
fi

## Remove sites that are no longer polymorphic.
START=$(date +%s)
echo -n "Removing sites that are no longer polymorphic... "
bcftools view -e 'AC==0 || AC==AN' -o t13.vcf t12.vcf &> ${log_with_absolute_path}
if [ ! -f t13.vcf ]; then
  echo
  echo "ERROR: File t13.vcf does not exist."
  echo "ERROR: Something must have gone wrong with removing monomorphic sites."
  exit 1
fi
length_t13=`bcftools view -H t13.vcf | wc -l`
rm t12.vcf
print_time $START
echo "-> Removed $(( ${length_t12} - ${length_t13} )) sites (before: ${length_t12}, after: ${length_t13})."

## Compress with bcftools.
START=$(date +%s)
echo -n "Compressing file ${filtered_vcfgz}... "
bcftools view -O z -o ${filtered_vcfgz} t13.vcf 2> ${log_with_absolute_path}
if [ ! -f ${filtered_vcfgz} ]; then
  echo
  echo "ERROR: File ${filtered_vcfgz} does not exist."
  echo "ERROR: Something must have gone wrong with compressing."
  exit 1
fi
rm t12.vcf
print_time $START

## Index with bcftools.
START=$(date +%s)
echo -n "Indexing file ${filtered_vcfgz}... "
bcftools index ${filtered_vcfgz} 2> ${log_with_absolute_path}
if [ ! -f ${filtered_vcfgz}.csi ]; then
  echo
  echo "ERROR: File ${filtered_vcfgz}.csi does not exist."
  echo "ERROR: Something must have gone wrong with indexing."
  exit 1
fi
print_time $START

## Copy the vcf.gz file, its index file, and its bed file back to the analysis directory.
START=$(date +%s)
echo -n "Copying file ${filtered_vcfgz} back to the analysis directory... "
cp ${filtered_vcfgz} ${filtered_vcfgz_with_absolute_path}
print_time $START
START=$(date +%s)
echo -n "Copying file ${filtered_vcfgz}.csi back to the analysis directory... "
cp ${filtered_vcfgz}.csi ${filtered_vcfgz_with_absolute_path}.csi
print_time $START
START=$(date +%s)
echo -n "Copying file ${indel_bed} back to the analysis directory... "
cp ${indel_bed} ${indel_bed_with_absolute_path}
print_time $START
