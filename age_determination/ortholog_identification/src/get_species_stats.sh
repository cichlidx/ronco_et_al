# m_matschiner Thu Nov 15 10:03:47 CET 2018

# This script has the following dependencies:
# concatenate.rb
# get_species_stats.rb

# Load modules.
module load ruby/2.1.5

# Concatenate the alignments for all genes.
ruby concatenate.rb -i ../res/alignments/nuclear/strict/*.nex -o tmp.strict.fasta -f fasta
ruby concatenate.rb -i ../res/alignments/nuclear/permissive/*.nex -o tmp.permissive.fasta -f fasta

# Get per-species stats from the concatenated alignment.
ruby get_species_stats.rb tmp.strict.fasta ../res/tables/species_stats_strict.txt
ruby get_species_stats.rb tmp.permissive.fasta ../res/tables/species_stats_permissive.txt

# Clean up.
rm -f tmp.strict.fasta
rm -f tmp.permissive.fasta
