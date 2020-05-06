# m_matschiner Sun Jul 22 15:34:34 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/alignments/nuclear/08
rm -rf ../res/alignments/nuclear/08/*

# Remove genes with too few exon alignments.
ruby filter_genes_by_exon_number.rb ../res/alignments/nuclear/07 ../res/alignments/nuclear/08 ../res/tables/orylat_ortholog_regions.txt ../../nuclear_queries_selection/res/tables/nuclear_queries_exons_miss0.txt 3