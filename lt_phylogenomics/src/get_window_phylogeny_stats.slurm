#!/bin/bash

# m_matschiner Fri Jun 29 11:52:50 CEST 2018

# Job name:
#SBATCH --job-name=wndstat
#
# Wall clock limit:
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=4G

## Set up the job environment.
source /cluster/bin/jobsetup

## Feedback.
echo
echo "get_window_phylogeny_stats.slurm was called with arguments ${@}."
echo

# Load the python2 and R modules.
module load python2/2.7.10
module load R/3.4.4

# Get the command-line arguments.
tree_dir=$1
tree_dir_with_absolute_path=`readlink -f ${tree_dir}`
chromosome_id=$2
ref_tree=$3
sample_table=$4
exclude_str=$5
ref_tree_with_absolute_path=`readlink -f ${ref_tree}`
rf_script=get_rf_distance.py
rf_script_with_absolute_path=`readlink -f get_rf_distance.py`
prune_script=prune_tree.r
prune_script_with_absolute_path=`readlink -f ${prune_script}`
gsi_script=get_gsi.r
gsi_script_with_absolute_path=`readlink -f ${gsi_script}`

# Make an assignment table for the gsi.
cat ${sample_table} | tail -n +2 | cut -f 1,4 > ${SCRATCH}/assignment.txt

# Change to temporary directory.
cd ${SCRATCH}

# Write the exclude string to a file.
echo ${exclude_str} | sed 's/,/\n/g' > exclude.txt

# Generate a newick version of the reference tree.
cat ${ref_tree_with_absolute_path} | grep "\[\&U\]" | tr -s " " | cut -d " " -f 6 > ref.tre

# Get the robinson-foulds distance and gsi values for the and add them to the info file.
for tree in ${tree_dir_with_absolute_path}/${chromosome_id}*.tre
do
    # Set the name of the info file.
    tree_id=`basename ${tree%.raxml.tre}`
    info=${tree%.raxml.tre}.info.txt

    # Feedback.
    echo -n "Analyzing tree ${tree_id}..."

    # Prune the sliding-window tree to a single tip per sample.
    cat ${tree} | sed 's/:/:\n/g' | sed 's/(/(\n/g' | sed 's/,/,\n/g' | grep ":" | grep -v ")" | sed 's/://g' | grep -vf exclude.txt | grep -v NC_ | grep -v UNPLACED | grep -v -e '^$' > keep.txt
    cat ${tree} | sed 's/_1//g' > window_renamed.tre
    Rscript ${prune_script_with_absolute_path} window_renamed.tre window_pruned.tre keep.txt
    Rscript ${prune_script_with_absolute_path} ref.tre ref_pruned.tre keep.txt

    # Calculate robinson-foulds distances.
    rf_dist_calculated=`cat ${info} | grep raxml_tree_rf_distance | wc -l`
    if [ ${rf_dist_calculated} == 0 ]
    then
	rf_dist=`python ${rf_script_with_absolute_path} window_pruned.tre ref_pruned.tre`
	echo "raxml_tree_rf_distance:${rf_dist}" >> ${info}
    fi

    # Calculate gsi values for various tribes.
    gsis_calculated=`cat ${info} | grep raxml_tree_gsi | wc -l`
    if [ ${gsis_calculated} == 0 ]
    then
	cat assignment.txt | grep -f keep.txt > assignment_pruned.txt
	gsi_ectodini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Ectodini"`
	gsi_lamprologini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Lamprologini"`
	gsi_eretmodini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Eretmodini"`
	gsi_tropheini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Tropheini"`
	gsi_cyprichromini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Cyprichromini"`
	gsi_benthochromini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Benthochromini"`
	gsi_perissodini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Perissodini"`
	gsi_limnochromini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Limnochromini"`
	gsi_bathybatini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Bathybatini"`
	gsi_trematocarini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Trematocarini"`
	gsi_cyphotilapiini=`Rscript ${gsi_script_with_absolute_path} window_pruned.tre assignment_pruned.txt "Cyphotilapiini"`
	echo "raxml_tree_gsi_Ectodini:${gsi_ectodini}" >> ${info}
	echo "raxml_tree_gsi_Lamprologini:${gsi_lamprologini}" >> ${info}
	echo "raxml_tree_gsi_Eretmodini:${gsi_eretmodini}" >> ${info}
	echo "raxml_tree_gsi_Tropheini:${gsi_tropheini}" >> ${info}
	echo "raxml_tree_gsi_Cyprichromini:${gsi_cyprichromini}" >> ${info}
	echo "raxml_tree_gsi_Benthochromini:${gsi_benthochromini}" >> ${info}
	echo "raxml_tree_gsi_Perissodini:${gsi_perissodini}" >> ${info}
	echo "raxml_tree_gsi_Limnochromini:${gsi_limnochromini}" >> ${info}
	echo "raxml_tree_gsi_Bathybatini:${gsi_bathybatini}" >> ${info}
	echo "raxml_tree_gsi_Trematocarini:${gsi_trematocarini}" >> ${info}
	echo "raxml_tree_gsi_Cyphotilapiini:${gsi_cyphotilapiini}" >> ${info}
    fi

    # Feedback.
    echo " done."

done
