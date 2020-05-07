# m_matschiner Thu May 30 14:19:56 CEST 2019

# Make the results directory.
mkdir -p ../res/tree_asymmetry

# Make the log directory.
mkdir -p ../log/tree_asymmetry

# Set the tree file.
trees=../res/iqtree/trees/loci.treefile

# Set the order file.
order_table=../data/tables/order.txt

# Analyze tree asymmetry.
while read line
do
    taxon2=${line}
    frequency_table=../res/tree_asymmetry/topology_frequencies_${taxon2}.txt
    out=../log/tree_asymmetry/tree_asymmetry_${taxon2}.out
    sbatch -o ${out} analyze_tree_asymmetry.slurm ${trees} ${taxon2} ${frequency_table}
done < ${order_table}
