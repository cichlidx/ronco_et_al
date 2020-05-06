# m_matschiner Sun Dec 16 01:15:02 CET 2018

# Make iqtree trees for all hypotheses.
for hypothesis in h09 # h08 h09 # h07  # h01 h02 h03 h04 h05 h06 h07 h08
do
    # Set the prefix of constraint trees.
    constraint_prefix=../data/constraints/${hypothesis}

    # Make iqtree trees for both exons and genes.
    for class in exons genes
        do
        # Make the log directory.
        mkdir -p ../log/iqtree_constrained/${hypothesis}/${class}

        # Set the alignment directory.
        alignment_dir=../res/alignments/permissive/${class}/phylip

        # Set the tree directory.
        res_dir=../res/iqtree_constrained/${hypothesis}/permissive/${class}

        # Make the tree directory.
        mkdir -p ${res_dir}

        # Run iqtree.
        for last_char in {0..9}
        do
            for second_last_char in {0..9}
            do
                out=../log/iqtree_constrained/${class}/permissive_${second_last_char}${last_char}.out
                rm -f ${out}
                sbatch -o ${out} run_iqtree_constrained.slurm ${alignment_dir} ${second_last_char} ${last_char} ${constraint_prefix} ${res_dir}
            done
        done
    done
done