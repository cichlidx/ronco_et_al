# m_matschiner Wed Jan 9 16:56:30 CET 2019

# Calculate gene and site concordance factors with iqtree.
concatenated=../res/iqtree/alignments/concatenated.nex
tree_dir=../res/iqtree/trees
concat_tree=../res/iqtree/trees/concat.treefile
loci_trees=../res/iqtree/trees/loci.treefile
prefix="concord"
out=../log/iqtree/concord.out
rm -f ${out}
sbatch -o ${out} run_iqtree_concord.slurm ${concat_tree} ${loci_trees} ${concatenated} ${tree_dir} ${prefix}
