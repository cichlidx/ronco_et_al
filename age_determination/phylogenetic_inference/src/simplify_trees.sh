# m_matschiner Fri Nov 16 00:11:57 CET 2018

# Dependencies:
# simplify_nexus_tree.r

# Load modules.
module load R/3.4.4

# Make results directories.
mkdir -p ../res/trees/strict
mkdir -p ../res/trees/permissive

# Simplify all trees files by removing the translation block.
for mode in strict permissive
do
    mkdir -p ../res/trees/${mode}
    for tree in ../data/trees/${mode}/ENS*.trees ../data/trees/${mode}/${mode}_numbered_mccs.trees
    do
	tree_base=`basename ${tree%.trees}`
	simplified_tree_name=`echo ../res/trees/${mode}/${tree_base}.trees | sed 's/_numbered//g'`
	if [ ! -f ../res/trees/${mode}/${tree_base}.trees ]
	then
	    Rscript simplify_tree.r ${tree} ${simplified_tree_name}
	    echo "Wrote file ${simplified_tree_name}."
	fi
    done
done