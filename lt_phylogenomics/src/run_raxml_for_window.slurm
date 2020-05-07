#!/bin/bash

# m_matschiner Sun Jul 22 20:47:55 CEST 2018

# Job name:
#SBATCH --job-name=winrxl
#
# Wall clock limit:
#SBATCH --time=3:00:00
#
# Processor and memory usage:
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G

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
module load ruby/2.1.5
module load python3/3.5.0
module load raxml/8.2.4

## Feedback.
echo
echo "run_raxml_for_window.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
region=${2}
masked_ref_with_relative_path=${3}
unmasked_ref_with_relative_path=${4}
sample_table_with_relative_path=${5}
sample_table_with_absolute_path=`readlink -f ${sample_table_with_relative_path}`
callability_mask_dir=${6}
exclude_str=${7}
missing_threshold_overall=${8}
missing_threshold_stdev=${9}
tree_with_relative_path=${10}
tree_with_absolute_path=`readlink -f ${tree_with_relative_path}`
log_with_relative_path=${11}
log_with_absolute_path=`readlink -f ${log_with_relative_path}`
info_with_relative_path=${12}
info_with_absolute_path=`readlink -f ${info_with_relative_path}`
extract_script_with_absolute_path=`readlink -f extract_alignment.rb`
convert_script_with_absolute_path=`readlink -f convert.py`
get_missing_script_with_absolute_path=`readlink -f get_proportion_of_missing_data.rb`
bmge_with_absolute_path=`readlink -f ../bin/BMGE.jar`
chromosome_id=`echo ${region} | cut -d ":" -f 1`

# Make sure an info file is there even if it's empty.
touch ${info_with_absolute_path}

# Extracting the region from the vcf file.
bcftools view -r "${region}" ${gzvcf_with_relative_path} > ${SCRATCH}/region.vcf

# Extracting the chromosome from the masked reference.
cat ${masked_ref_with_relative_path} | grep -A 1 ${chromosome_id} > ${SCRATCH}/ref_chromosome_masked.fasta

# Extracting the chromosome from the unmasked reference.
cat ${unmasked_ref_with_relative_path} | grep -A 1 ${chromosome_id} > ${SCRATCH}/ref_chromosome.fasta

# Make subsets of the callability masks.
START=$(date +%s)
echo -n "Making subsets of callability masks... "
for i in ${callability_mask_dir}/*.bed.bgz
do
    file_id=`basename ${i%.bed.bgz}`
    sample_id=`echo ${file_id} | cut -d "." -f 1`
    tabix -p bed ${i} ${region} > ${SCRATCH}/${sample_id}.bed
done
print_time $START

# Move to the temporary directory.
cd ${SCRATCH}

# Make a table assigning all samples to tribes. 
cat ${sample_table_with_absolute_path} | tail -n +2 | cut -f 1,4 > all_samples_with_tribes.txt

# Write the exclude string to a file.
echo ${exclude_str} | sed 's/,/\n/g' > exclude.txt

# Use a ruby script to extract the alignment.
START=$(date +%s)
echo -n "Extracting alignment for region from vcf... "
ruby ${extract_script_with_absolute_path} region.vcf ${region} ref_chromosome_masked.fasta ref_chromosome.fasta 1 alignment.phy
print_time $START

# Remove low-quality samples and reduce the alignment to a single allele per sample.
START=$(date +%s)
echo -n "Removing low-quality samples... "
cat alignment.phy | grep -vf exclude.txt | tail -n +2 > tmp.txt
n_char=`head -n 1 alignment.phy | cut -d " " -f 2`
n_taxa=`cat tmp.txt | wc -l`
echo "${n_taxa} ${n_char}" > alignment_red.phy
cat tmp.txt >> alignment_red.phy
print_time $START

# Get the proportion of missing data for the alignment with all samples unless this has already been done.
proportion_missing_calculated=`cat ${info_with_absolute_path} | grep "proportion_missing:" | wc -l`
if [ ${proportion_missing_calculated} == 0 ]
then
    START=$(date +%s)
    echo -n "Calculating the proportion of missing data for full alignment... "
    python3 ${convert_script_with_absolute_path} -f nexus alignment_red.phy alignment_red.nex
    proportion_missing=`ruby ${get_missing_script_with_absolute_path} alignment_red.nex`
    echo "proportion_missing:${proportion_missing}" >> ${info_with_absolute_path}
    print_time $START
else
    proportion_missing=`cat ${info_with_absolute_path} | grep "proportion_missing:" | cut -d ":" -f 2`
fi

# Calculate the standard deviation of missing data across tribes unless this has been done.
proportion_missing_stdev_calculated=`cat ${info_with_absolute_path} | grep "proportion_missing_stdev:" | wc -l`
if [ ${proportion_missing_stdev_calculated} == 0 ]
then

    # Make a list of the ids of those samples that are included in the alignment.
    cat tmp.txt | tail -n +2 | cut -d " " -f 1 > included_samples.txt
    rm tmp.txt
    
    # Make a table assigning only the included samples to tribes.
    cat all_samples_with_tribes.txt | grep -f included_samples.txt > included_samples_with_tribes.txt

    # Make a separate alignment for each tribe.
    START=$(date +%s)
    echo -n "Calculating per-tribe proportions of missing data... "
    tribes=`cat included_samples_with_tribes.txt | cut -f 2 | sort | uniq -c | grep -v " 1 " | grep -v " 2 " | grep -v " 3 " | tr -s " " | cut -d " " -f 3`
    for tribe in ${tribes}
    do
	cat included_samples_with_tribes.txt | grep ${tribe} | cut -f 1 > included_samples_of_${tribe}.txt
	n_taxa_tribe=`cat included_samples_of_${tribe}.txt | wc -l`
	echo "${n_taxa_tribe} ${n_char}" > alignment_red_${tribe}.phy
	cat alignment_red.phy | grep -f included_samples_of_${tribe}.txt >> alignment_red_${tribe}.phy
	python3 ${convert_script_with_absolute_path} -f nexus alignment_red_${tribe}.phy alignment_red_${tribe}.nex
	proportion_missing_tribe=`ruby ${get_missing_script_with_absolute_path} alignment_red_${tribe}.nex`
	echo "proportion_missing_${tribe}:${proportion_missing_tribe}" >> ${info_with_absolute_path}
    done
    print_time $START

    # Get the standard deviation of the proportion of missing data per tribe.
    proportion_missing_stdev=`cat ${info_with_absolute_path} | grep proportion_missing_ | grep -v stdev | cut -d ":" -f 2 | awk '{x+=$0;y+=$0^2}END{print sqrt(y/NR-(x/NR)^2)}'`
    echo "proportion_missing_stdev:${proportion_missing_stdev}" >> ${info_with_absolute_path}

else
    proportion_missing_stdev=`cat ${info_with_absolute_path} | grep "proportion_missing_stdev:" | cut -d ":" -f 2`

fi

# Quit if the proportion of missing data is above the threshold.
if (( $(echo "${proportion_missing} > ${missing_threshold_overall}" | bc -l) ))
then
    echo "Skipping rest of analyses due to large overall proportion of missing data (${proportion_missing})."
    exit 
fi

# Quit if the standard deviation of the proportion of missing data is above the threshold.
if (( $(echo "${proportion_missing_stdev} > ${missing_threshold_stdev}" | bc -l) ))
then
    echo "Skipping rest of analyses due to large standard deviation of the proportion of missing data (${proportion_missing_stdev})."
    exit
fi

# Prepare and run a raxml analysis unless this has been attempted before.
raxml_launched=`cat ${info_with_absolute_path} | grep "raxml_launched:yes" | wc -l`
if [ ${raxml_launched} == 0 ]
then

    # Run bgme to remove sites with large gap proportion.
    START=$(date +%s)
    echo -n "Running BMGE... "
    java -jar ${bmge_with_absolute_path} -i alignment_red.phy -t DNA -o alignment_red_clean.phy >> ${log_with_absolute_path}
    print_time $START

    # Run raxml.
    START=$(date +%s)
    echo -n "Running RAxML... "
    # raxmlHPC -s alignment_red_clean.phy -n tmp -m GTRCAT -N 3 -p ${RANDOM} >> ${log_with_absolute_path}
    raxmlHPC-PTHREADS -T 5 -s alignment_red_clean.phy -n tmp -m GTRCAT -N 3 -p ${RANDOM} >> ${log_with_absolute_path}
    echo "raxml_launched:yes" >> ${info_with_absolute_path}
    print_time $START

    # Copy the result files to the results directory.
    cp RAxML_bestTree.tmp ${tree_with_absolute_path}
    cat RAxML_info.tmp >> ${log_with_absolute_path}

else
    echo "Skipping raxml analysis as it has been launched before."
    exit

fi