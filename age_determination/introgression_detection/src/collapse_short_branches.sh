# m_matschiner Fri Dec 14 11:09:46 CET 2018

# Make the log directory.
mkdir -p ../log/misc

# Collapse nodes connected by short branches. 
for mode in strict permissive
do
    for class in exons genes
    do
	tree_dir=../res/iqtree/${mode}/${class}
	clean_tree_dir=../res/clean_trees/${mode}/${class}
	mkdir -p ${clean_tree_dir}
	for last_char in {0..9}
	do
	    out=../log/misc/collapse_nodes_${mode}_${class}_iqtree_minlength_${last_char}.out
	    rm -f ${out}
	    sbatch -o ${out} collapse_short_branches.slurm ${tree_dir} ${last_char} ${clean_tree_dir}
	done
    done
done
