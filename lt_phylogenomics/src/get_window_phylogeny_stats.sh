# m_matschiner Mon Aug 13 18:47:21 CEST 2018

# Make the output directory.
mkdir -p ../res/tables/windows

# Make the log directory.
mkdir -p ../log/misc

# Set the assignment table.
sample_table=../data/tables/DNATube_2018-02-13_13-43.tsv

# Set the name of the reference tree.
ref_tree=../res/raxml/full/permissive.c60.tre

# Define samples to be excluded.
exclude_str="Bel33,LJD1,LJC9"

# Get stats for all trees of all chromosomes.
for chromosome_id in NC_0319{65..87} UNPLACED
do
    # Set the directory with trees.
    tree_dir=../res/windows/5000bp/${chromosome_id}

    # Set the log file.
    out=../log/misc/get_window_phylogeny_stats.${chromosome_id}.txt

    # Get stats for all trees of this chromosome.
    rm -f ${out}
    sbatch -o ${out} get_window_phylogeny_stats.slurm ${tree_dir} ${chromosome_id} ${ref_tree} ${sample_table} ${exclude_str}
done