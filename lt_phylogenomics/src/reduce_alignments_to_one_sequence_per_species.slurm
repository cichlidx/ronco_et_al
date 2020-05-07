#!/bin/bash

# m_matschiner Thu Oct 11 21:32:06 CEST 2018

# Job name:
#SBATCH --job-name=redaln
#
# Wall clock limit:
#SBATCH --time=20:00:00
#
# Processor and memory usage:
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G

## Set up the job environment.
source /cluster/bin/jobsetup

## Feedback.
echo
echo "reduce_alignments_to_one_sequence_per_species.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
align_dir_with_relative_path=${1} # ../res/windows/5000bp/NC_031965
align_dir_with_absolute_path=`readlink -f ${align_dir_with_relative_path}`
completeness_table_with_relative_path=${2}
completeness_table_with_absolute_path=`readlink -f ${completeness_table_with_relative_path}`
sample_table_with_relative_path=${3} # ../data/tables/DNATube_2018-02-13_13-43.tsv
sample_table_with_absolute_path=`readlink -f ${sample_table_with_relative_path}`
first_align_with_absolute_path=`ls ${align_dir_with_absolute_path}/*.phy | head -n 1`

# Move to the temporary directory.
cd ${SCRATCH}

# Make a list of the one specimen per species that has the lowest proportion of missing data.
rm -f tmp.best_specimens.txt
touch tmp.best_specimens.txt
tail -n +2 ${first_align_with_absolute_path} | cut -d " " -f 1 > tmp.specimens_in_alignment.txt
cat ${sample_table_with_absolute_path} | grep -f tmp.specimens_in_alignment.txt | cut -f 3 | sort | uniq> tmp.species_in_alignment.txt
cat ${sample_table_with_absolute_path} | grep -f tmp.specimens_in_alignment.txt | cut -f 1,3 > tmp.species_and_specimens_in_alignment.txt
while read line
do
    cat tmp.species_and_specimens_in_alignment.txt | grep ${line} | cut -f 1 > tmp.specimens_for_this_species.txt
    cat ${completeness_table_with_absolute_path} | grep -f tmp.specimens_for_this_species.txt | sort -n -k 4 | head -n 1 | cut -f 1 >> tmp.best_specimens.txt
done < tmp.species_in_alignment.txt
cat tmp.species_and_specimens_in_alignment.txt | grep -f tmp.best_specimens.txt > tmp.species_and_best_specimens_in_alignment.txt
rm -f tmp.specimens_in_alignment.txt
rm -f tmp.species_in_alignment.txt
rm -f tmp.species_and_specimens_in_alignment.txt
rm -f tmp.specimens_for_this_species.txt

# Make a new reduced version of each window alignment in the alignment directory.
for align in ${align_dir_with_absolute_path}/*[0-9].phy
do
    # Set the name of the reduced alignment.
    reduced_align_with_absolute_path=${align%.phy}.species.phy

    # Generate a reduced version of the alignment with just one sequence per species.
    tail -n +2 ${align} | grep -f tmp.best_specimens.txt | tr -s " "  > tmp.alignment.txt
    while read line
    do
        specimen=`echo ${line} | cut -d " " -f 1`
        species=`echo ${line} | cut -d " " -f 2`
        cat tmp.alignment.txt | sed "s/${specimen}/${species} /g" > tmp.new_alignment.txt
        rm -f tmp.alignment.txt
        mv tmp.new_alignment.txt tmp.alignment.txt
    done < tmp.species_and_best_specimens_in_alignment.txt
    n_tax=`cat tmp.alignment.txt | wc -l`
    n_char=`head -n 2 tmp.alignment.txt | tail -n 1 | tr -s " " | cut -d " " -f 2 | tr -d "\n" | wc -m`
    echo "${n_tax} ${n_char}" > tmp.reduced_alignment.phy
    cat tmp.alignment.txt >> tmp.reduced_alignment.phy

    # Copy the reduced alignment back to the alignment directory.
    cp tmp.reduced_alignment.phy ${reduced_align_with_absolute_path}
    echo "Wrote ${reduced_align_with_absolute_path}."

    # Clean up.
    rm -f tmp.alignment.txt
    rm -f tmp.reduced_alignment.phy
done

