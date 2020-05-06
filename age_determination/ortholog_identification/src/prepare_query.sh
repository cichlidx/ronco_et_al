# m_matschiner Tue Nov 6 17:12:01 CET 2018

# This script has the following dependencies:
# remove_empty_seqs_from_fasta.rb

# Load the ruby module.
module load ruby/2.1.5

# Make the queries directory.
mkdir -p ../data/queries

# Copy the medaka exons in amino-acid format.
cp ../../nuclear_queries_selection/res/queries/orylat_exons_miss0.fasta tmp.fasta
cp ../../nuclear_queries_selection/res/tables/nuclear_queries_exons_miss0.txt ../data/tables

# Remove empty sequences from the fasta file.
ruby remove_empty_seqs_from_fasta.rb tmp.fasta ../data/queries/orylat_exons.fasta

# Count and report the number of exons in the fasta file.
count=`cat ../data/queries/orylat_exons.fasta | grep ">" | wc -l`
echo "Fasta file contains ${count} sequences."

# Clean up.
rm -f tmp.fasta