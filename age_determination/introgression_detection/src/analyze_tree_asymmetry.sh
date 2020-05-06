# m_matschiner Thu Dec 13 16:33:16 CET 2018

# Make the output directory.
mkdir -p ../res/tables

# Analyze tree asymmetry in all sets of trees.
for mode in strict permissive
do
    for class in exons genes
    do
	# Set the input tree directory.
        clean_tree_dir=../res/clean_trees/${mode}/${class}

	# Set the ouput table.
	table=../res/tables/tree_asymmetry_${mode}_${class}.txt

	# Analyze tree asymmetry.
	out=../log/misc/tree_asymmetry_${mode}_${class}.out
	rm -f ${out}
	sbatch -o ${out} analyze_tree_asymmetry.slurm ${clean_tree_dir} ${table}
    done
done
