# m_matschiner Tue Nov 20 00:58:46 CET 2018

# Load modules.
module load ruby/2.1.5

# Make the results directory.
mkdir -p ../res/alignments
mkdir -p ../res/tables

# Find all indels and the taxa affected by it.
for mode in strict permissive
do
    ruby find_indels.rb ../res/alignments/02_${mode} 5 ../res/tables/indels_${mode}.txt ../res/alignments/02_${mode}_indels.nex
done