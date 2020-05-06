#!/bin/bash

# m_matschiner Tue Dec 4 14:11:15 CET 2018

#SBATCH --job-name=iqtree
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=5

# Set up.
source /cluster/bin/jobsetup
module load iqtree/1.6.8
module load R/3.4.4

# Get the command-line arguments.
alignment_dir=`readlink -f ${1}`
second_last_char=${2}
last_char=${3}
constraint_prefix=`readlink -f ${4}`
tree_dir=`readlink -f ${5}`

# Change to the temporary directory.
cd ${SCRATCH}

# Run iqtree for all alignments of the permissive dataset.
for phylip in ${alignment_dir}/*${second_last_char}${last_char}.phy
do
    marker_id=`basename ${phylip%.phy}`
    echo -n "Analyzing alignment ${marker_id}.phy..."
    for constraint_tree in ${constraint_prefix}*.tre
    do
	constraint_id=`basename ${constraint_tree%.tre}`
	info=${tree_dir}/${marker_id}_${constraint_id}.info.txt
	if [ ! -f ${info} ]
	then
	    # Copy the alignment file to the temporary directory.
	    cp -f ${phylip} tmp.iqtree.phy
	
	    # Copy the constraint tree without comment line to the temporary directory.
	    cat ${constraint_tree} | grep -v "#" > tmp.constraint.tre

	    # Remove taxa from the constraint tree that don't occur in the alignment.
	    cat tmp.constraint.tre | tr -d "(" | tr -d ")" | tr -d ";" | tr "," "\n" | sed "/^$/d" | sort > tmp.taxa_in_constraint_tree.txt
	    cat tmp.iqtree.phy | tail -n +2 | cut -d " " -f 1 | sort > tmp.taxa_in_align.txt
	    taxa_missing_in_align=`comm -23 tmp.taxa_in_constraint_tree.txt tmp.taxa_in_align.txt`
	    for taxon in ${taxa_missing_in_align}
	    do
		cat tmp.constraint.tre | sed "s/${taxon}//g" | sed "s/,,/,/g" | sed "s/,)/)/g" | sed "s/(,/(/g" > tmp.constraint2.tre
		mv -f tmp.constraint2.tre tmp.constraint.tre
	    done

	    # Check if a constraint now includes just a single taxon.
	    single_taxon_constraint_found=0
	    for taxon in `cat tmp.taxa_in_align.txt`
	    do
		this_single_taxon_constraint_found=`cat tmp.constraint.tre | grep "(${taxon})" | wc -l`
		if [[ ${this_single_taxon_constraint_found} == 1 ]]
		then
		    single_taxon_constraint_found=1
		fi
	    done
	    
	    # Run iqtree.
	    if [[ ${single_taxon_constraint_found} == 0 ]]
	    then
		iqtree -nt 5 -s tmp.iqtree.phy -m GTR -g tmp.constraint.tre --runs 2 -quiet
		mv -f tmp.iqtree.phy.iqtree ${info}
	    else
		echo "Skipping alignment due to too much missing data."
		echo -n "  Constraint string: "
		cat tmp.constraint.tre
	    fi

	    # Clean up.
	    rm -f tmp.iqtree.*
	    rm -f tmp.constraint.tre
	    rm -f tmp.taxa_in_constraint_tree.txt
	    rm -f tmp.taxa_in_align.txt
	fi
    done
    echo " done."
done