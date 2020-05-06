# m_matschiner Sun Jul 22 15:32:33 CEST 2018

# Make the output directory.
mkdir -p ../res/alignments/nuclear/09
rm -rf ../res/alignments/nuclear/09/*

# Make the log directory.
mkdir -p ../log/misc

# Set the input and output directories.
indir=../res/alignments/nuclear/08
outdir=../res/alignments/nuclear/09

# Set the name of the input exon info table.
exon_info_table_in=../data/tables/nuclear_queries_exons_miss0.txt

# Set the minimum number of exons that should remain per gene.
min_n_exons_per_gene=3

# Set the paths to raxml and concaterpillar.
raxml_bin=../bin/raxmlHPC
concaterpillar_dir=../bin/concaterpillar

# Set the number of cpus to be used.
n_cpus=10

# For each gene, run concaterpillar with all exons, and remove those that do not fall into the main cluster.
for second_last_char in `seq 0 9`
do
    for last_char in `seq 0 9`
    do
	out=../log/misc/concaterpillar_${second_last_char}${last_char}.out
	rm -f ${out}
	exon_info_table_out=../res/tables/nuclear_queries_exons_miss0_${second_last_char}${last_char}.txt
	sbatch -o ${out} filter_genes_by_exon_tree_congruence.slurm ${indir} ${last_char} ${second_last_char} ${outdir} ${exon_info_table_in} ${exon_info_table_out} ${min_n_exons_per_gene} ${raxml_bin} ${concaterpillar_dir} ${n_cpus}
    done
done