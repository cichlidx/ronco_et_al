#!/bin/bash

# m_matschiner Wed May 2 12:52:35 CEST 2018

# Job name:
#SBATCH --job-name=fixanc
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=10G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5
module load bcftools/1.6

## Feedback.
echo
echo "analyze_fixed_site_ancestry.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
file_id=`basename ${gzvcf_with_relative_path%.vcf.gz}`
gzvcf=`basename ${gzvcf_with_absolute_path}`
sample_table_with_relative_path=${2}
sample_table_with_absolute_path=`readlink -f ${sample_table_with_relative_path}`
species=${3}
spc_o=`echo ${species} | cut -d "," -f 4`
spc_p3=`echo ${species} | cut -d "," -f 3`
spc_p2=`echo ${species} | cut -d "," -f 2`
spc_p1=`echo ${species} | cut -d "," -f 1`
output_table_with_relative_path=${4}
output_table_with_absolute_path=`readlink -f ${output_table_with_relative_path}`
output_plot_with_relative_path=${5}
output_plot_with_absolute_path=`readlink -f ${output_plot_with_relative_path}`

# Feedback.
echo "Input vcf file: ${gzvcf_with_absolute_path}."
echo "Input sample table file: ${sample_table_with_absolute_path}."
echo "Species string: ${species}."
echo

# Copy the vcf file to the temporary directory.
cp ${gzvcf_with_absolute_path} ${SCRATCH}

# Copy scripts to the temporary directory.
cp determine_alleles_for_sites_fixed_in_parents.rb ${SCRATCH}
cp plot_ancestry.rb ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Make lists of species and samples.
for i in `zcat ${gzvcf_with_absolute_path} | head -n 1000 | grep CHROM | cut -f 10-`
do
    cat ${sample_table_with_absolute_path} | grep "^${i}"
done | cut -f 1,3 > all_samples.txt
cat all_samples.txt | grep -e ${spc_o} -e ${spc_p3} -e ${spc_p2} -e ${spc_p1} | sort > samples.txt

# Get the sample ids for the four species.
samples_o=`cat all_samples.txt | grep ${spc_o} | cut -f 1`
samples_p3=`cat all_samples.txt | grep ${spc_p3} | cut -f 1`
samples_p2=`cat all_samples.txt | grep ${spc_p2} | cut -f 1`
samples_p1=`cat all_samples.txt | grep ${spc_p1} | cut -f 1`

# Feedback.
str="Outgroup: ${spc_o} (samples: "
for i in ${samples_o}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
str="P3: ${spc_p3} (samples: "
for i in ${samples_p3}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
str="P2: ${spc_p2} (samples: "
for i in ${samples_p2}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
str="P1: ${spc_p1} (samples: "
for i in ${samples_p1}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
echo

# Make a subset of the vcf file.
echo -n "Subsetting the vcf file with bcftools..."
samples_all=`echo ${samples_o}; echo ${samples_p3}; echo ${samples_p2}; echo "${samples_p1}"`
samples_str=`echo ${samples_all} | sed 's/ /,/g'`
bcftools view -s `echo -n ${samples_str}` -a --min-ac=1 -O z -o t1.vcf.gz ${gzvcf}
bcftools view -e 'AC==0 || AC==AN || F_MISSING > 0.5' -m2 -M2 -o t2.vcf t1.vcf.gz
echo " done."

# Determine sites that are fixed between the parental species p1 and p3 and their state in species p2.
echo -n "Analyzing sites that are fixed in the parental species..."
ruby determine_alleles_for_sites_fixed_in_parents.rb t2.vcf output.txt `echo ${samples_p1} | sed 's/ /,/g'` `echo ${samples_p3} | sed 's/ /,/g'` `echo ${samples_p2} | sed 's/ /,/g'` 1.0
echo " done."

# Copy the output table back to the result directory.
echo -n "Copying the output table to ${output_table_with_absolute_path}..." 
cp output.txt ${output_table_with_absolute_path}
echo " done."

# Plot the ancestry of sites that are fixed between the parental species.
echo "Plotting allelic states of sites fixed in the parental species..."
ruby plot_ancestry.rb output.txt output.svg 1.0 100000
echo " done."

# Copy the output plot back to the result directory.
echo -n "Copying the output plot to ${output_plot_with_absolute_path}..."
cp output.svg ${output_plot_with_absolute_path}
echo " done."
