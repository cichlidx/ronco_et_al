# m_matschiner Tue Dec 4 14:11:15 CET 2018

# Make iqtree trees for both exons and genes.
for class in exons genes
do
    # Make the log directory.
    mkdir -p ../log/iqtree/${class}

    # Set the alignment directory.
    alignment_dir=../res/alignments/permissive/${class}/phylip

    # Set the tree directory.
    tree_dir=../res/iqtree/permissive/${class}

    # Make the tree directory.
    mkdir -p ${tree_dir}

    # Set the constraint files.
    constraint_tree=../data/constraints/order_monophyly.tre
    constraint_tree_wo_parpar=../data/constraints/order_monophyly_wo_parpar.tre

    # Run iqtree.
    for last_char in {0..9}
    do
	for second_last_char in {0..9}
	do
	    out=../log/iqtree/${class}/permissive_${second_last_char}${last_char}.out
	    rm -f ${out}
	    sbatch -o ${out} run_iqtree.slurm ${alignment_dir} ${second_last_char} ${last_char} ${constraint_tree} ${constraint_tree_wo_parpar} ${tree_dir}
	    exit
	done
    done
done