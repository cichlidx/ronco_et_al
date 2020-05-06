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
constraint_tree=`readlink -f ${4}`
constraint_tree_wo_parpar=`readlink -f ${5}`
tree_dir=`readlink -f ${6}`
r_script=`readlink -f reroot_tree.r`

# Change to the temporary directory.
cd ${SCRATCH}

# Run iqtree for all alignments of the permissive dataset.
for phylip in ${alignment_dir}/*${second_last_char}${last_char}.phy
do
    marker_id=`basename ${phylip%.phy}`
    echo -n "Analyzing alignment ${marker_id}.phy..."
    info=${tree_dir}/${marker_id}.info.txt
    tree=${tree_dir}/${marker_id}.tre
    if [ ! -f ${tree} ]
    then
	cp -f ${phylip} tmp.iqtree.phy
	
	# Determine which constraint tree to use.
	parpar_included=`cat tmp.iqtree.phy | grep parpar | wc -l`
	if [[ ${parpar_included} == 1 ]]
	then
	    cp -f ${constraint_tree} tmp.constraint.tre
	elif [[ ${parpar_included} == 0 ]]
	then
	    cp -f ${constraint_tree_wo_parpar} tmp.constraint.tre
	else
	    echo "ERROR: Unexpected number of occurrences of 'parpar'!"
	    exit 1
	fi

	# Remove taxa from the constraint tree that don't occur in the alignment.
	cat tmp.constraint.tre | tr -d "(" | tr -d ")" | tr -d ";" | tr "," "\n" | sed "/^$/d" | sort > tmp.taxa_in_constraint_tree.txt
	cat tmp.iqtree.phy | tail -n +2 | cut -d " " -f 1 | sort > tmp.taxa_in_align.txt
	taxa_missing_in_align=`comm -23 tmp.taxa_in_constraint_tree.txt tmp.taxa_in_align.txt`
	for taxon in ${taxa_missing_in_align}
	do
	    cat tmp.constraint.tre | sed "s/${taxon}//g" | sed "s/,,/,/g" | sed "s/,)/)/g" | sed "s/(,/(/g" > tmp.constraint2.tre
	    mv -f tmp.constraint2.tre tmp.constraint.tre
	done
	for taxon in orylat krymar cypvar funhet notfur poefor xipmac
	do
	    cat tmp.constraint.tre | sed "s/(${taxon})/${taxon}/g" > tmp.constraint2.tre
	    mv -f tmp.constraint2.tre tmp.constraint.tre
	done
        for taxon in orylat krymar cypvar funhet notfur poefor xipmac
        do
	    taxon_alone=`cat tmp.constraint.tre | grep "(${taxon},(" | wc -l`
	    if [[ ${taxon_alone} == 1 ]]
	    then
		cat tmp.constraint.tre | sed "s/(${taxon},(/(${taxon},/g" | sed "s/))/)/g" > tmp.constraint2.tre
		mv -f tmp.constraint2.tre tmp.constraint.tre
	    fi
        done
	
	# Run iqtree.
	iqtree -nt 5 -s tmp.iqtree.phy -m TEST -g tmp.constraint.tre --runs 2 -quiet

	# Reroot the tree.
	if [[ ${parpar_included} == 1 ]]
	then
	    Rscript ${r_script} tmp.iqtree.phy.treefile tmp.rooted.tre parpar
	elif [[ ${parpar_included} == 0 ]]
	then
	    outgroup=`cat tmp.taxa_in_align.txt | grep -e orylat -e krymar -e cypvar -e funhet -e notfur -e poefor -e xipmac | tr "\n" " "`
	    Rscript ${r_script} tmp.iqtree.phy.treefile tmp.rooted.tre ${outgroup}
	fi

	# Return the result files.
	mv -f tmp.rooted.tre ${tree}
	mv -f tmp.iqtree.phy.iqtree ${info}

	# Clean up.
	rm -f tmp.iqtree.*
	rm -f tmp.constraint.tre
	rm tmp.taxa_in_constraint_tree.txt
	rm tmp.taxa_in_align.txt
    fi
    echo " done."
done