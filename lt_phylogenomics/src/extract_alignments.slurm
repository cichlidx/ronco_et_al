#!/bin/bash

# m_matschiner Sun Jul 22 20:47:55 CEST 2018

# Job name:
#SBATCH --job-name=extraln
#
# Wall clock limit:
#SBATCH --time=168:00:00
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
echo "extract_alignments.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
tree_dir_with_relative_path=${2}
tree_dir_with_absolute_path=`readlink -f ${tree_dir_with_relative_path}`
max_rf_distance=${3}
masked_ref_with_relative_path=${4}
masked_ref_with_absolute_path=`readlink -f ${masked_ref_with_relative_path}`
unmasked_ref_with_relative_path=${5}
unmasked_ref_with_absolute_path=`readlink -f ${unmasked_ref_with_relative_path}`
callability_mask_dir_with_relative_path=${6}
callability_mask_dir_with_absolute_path=`readlink -f ${callability_mask_dir_with_relative_path}`
exclude_str=${7}
log_with_relative_path=${8}
log_with_absolute_path=`readlink -f ${log_with_relative_path}`
extract_script_with_absolute_path=`readlink -f extract_alignment.rb`
convert_script_with_absolute_path=`readlink -f convert.py`
get_missing_script_with_absolute_path=`readlink -f get_proportion_of_missing_data.rb`
bmge_with_absolute_path=`readlink -f ../bin/BMGE.jar`

# Copy some of the script to the temporary directory.
cp get_number_of_variable_sites.rb ${SCRATCH}
cp get_parsimony_score.sh ${SCRATCH}
cp get_number_of_hemiplasies.sh ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Write the exclude string to a file.
echo ${exclude_str} | sed 's/,/\n/g' > exclude.txt

# Only consider windows for which raxml trees have already been produced.
for tree in ${tree_dir_with_absolute_path}/*.raxml.tre
do

    # Set the info file.
    info_with_absolute_path=${tree%.raxml.tre}.info.txt

    # Set the alignment file.
    align_with_absolute_path=${tree%.raxml.tre}.phy

    # Make sure that the info file exists.
    if [ ! -f ${info_with_absolute_path} ]
    then
        echo "ERROR: Info file ${info_with_absolute_path} could not be found!"
        exit 1
    fi

    # Get the window coordinates.
    window_id=`basename ${tree%.raxml.tre}`
    chromosome_id=`echo ${window_id} | rev | cut -d "_" -f 3- | rev`
    from=`echo ${window_id} | rev | cut -d "_" -f 2 | rev`
    to=`echo ${window_id} | rev | cut -d "_" -f 1 | rev`
    region="${chromosome_id}:${from}-${to}"

    # Check if the rf distance has already been calculated and warn if it hasn't.
    rf_distance_calculated=`cat ${info_with_absolute_path} | grep "raxml_tree_rf_distance:" | wc -l`
    if [[ ${rf_distance_calculated} == 1 ]]
    then

        # Check if the rf distance is small enough.
        rf_distance=`cat ${info_with_absolute_path} | grep "raxml_tree_rf_distance:" | cut -d ":" -f 2`
        if (( ${rf_distance} <= ${max_rf_distance} ))
        then
            # Extract the chromosome from the masked reference.
            if [ ! -f ref_chromosome_masked.fasta ]
            then
                cat ${masked_ref_with_absolute_path} | grep -A 1 ${chromosome_id} > ref_chromosome_masked.fasta
            fi

            # Extract the chromosome from the unmasked reference.
            if [ ! -f ref_chromosome.fasta ]
            then
                cat ${unmasked_ref_with_absolute_path} | grep -A 1 ${chromosome_id} > ref_chromosome.fasta
            fi

            rm -f *.bed
            START=$(date +%s)
            echo -n "Making subsets of callability masks... "
            for bed in ${callability_mask_dir_with_absolute_path}/*.bed.bgz
            do
                file_id=`basename ${bed%.bed.bgz}`
                sample_id=`echo ${file_id} | cut -d "." -f 1`
                tabix -p bed ${bed} ${region} > ${sample_id}.bed
            done
            print_time $START

            # Extracting the region from the vcf file.
            START=$(date +%s)
            echo -n "Making a subset vcf with bcftools... "
            bcftools view -r "${region}" ${gzvcf_with_absolute_path} > region.vcf
            print_time $START

            # Use a ruby script to extract the alignment from the vcf, using only a single allele per sample.
            START=$(date +%s)
            echo -n "Extracting alignment for region ${region} from vcf... "
            ruby ${extract_script_with_absolute_path} region.vcf ${region} ref_chromosome_masked.fasta ref_chromosome.fasta 1 alignment.phy
            print_time $START

            # Remove low-quality samples and the reference sequence.
            START=$(date +%s)
            echo -n "Removing low-quality samples... "
            cat alignment.phy | grep -vf exclude.txt | tail -n +3 > tmp.txt
            n_char=`head -n 1 alignment.phy | cut -d " " -f 2`
            n_taxa=`cat tmp.txt | wc -l`
            echo "${n_taxa} ${n_char}" > alignment_red.phy
            cat tmp.txt >> alignment_red.phy
            print_time $START

            # Run bmge to remove sites with large gap proportion.
            START=$(date +%s)
            echo -n "Running BMGE... "
            java -jar ${bmge_with_absolute_path} -i alignment_red.phy -t DNA -o alignment_red_clean.phy >> ${log_with_absolute_path}
            print_time $START

            # Convert the alignment to nexus format.
            START=$(date +%s)
            echo -n "Converting the alignment to nexus format... "
            python3 ${convert_script_with_absolute_path} -f nexus alignment_red_clean.phy alignment_red_clean.nex
            print_time $START

            # Get the alignment length after bmge filtering.
            alignment_length_after_bmge_calculated=`cat ${info_with_absolute_path} | grep "alignment_length_after_bmge:" | wc -l`
            if [[ ${alignment_length_after_bmge_calculated} == 0 ]]
            then
                START=$(date +%s)
                echo -n "Determining the alignment length after filtering with BMGE... "
                alignment_length_after_bmge=`head alignment_red_clean.nex | grep nchar | cut -d "=" -f 3 | tr -d ";"`
                echo "alignment_length_after_bmge:${alignment_length_after_bmge}" >> ${info_with_absolute_path}
                print_time $START
            fi

            # Calculate the number of variable sites.
            n_variable_sites_after_bmge_calculated=`cat ${info_with_absolute_path} | grep "n_variable_sites_after_bmge:" | wc -l`
            if [[ ${n_variable_sites_after_bmge_calculated} == 0 ]]
            then
                START=$(date +%s)
                echo -n "Calculating the number of variable sites... "
                n_variable_sites_after_bmge=`ruby get_number_of_variable_sites.rb alignment_red_clean.nex`
                echo "n_variable_sites_after_bmge:${n_variable_sites_after_bmge}" >> ${info_with_absolute_path}
                print_time $START
            fi

            # Copy the alignment to the results directory.
            if [ ! -f ${align_with_absolute_path} ]
            then
                START=$(date +%s)
                echo -n "Copying alignment to ${align_with_absolute_path}... "
                cp alignment_red_clean.phy ${align_with_absolute_path}
                print_time $START
            fi
        fi
    else
        echo "WARNING: No Robinson-Foulds distance calculated for window ${region}. Skipping this window."
    fi
done