# m_matschiner Fri Nov 16 10:36:49 CET 2018

# Make simple newick versions of all sets of gene trees and mcc tree sets.
bash simplify_trees.sh

# Run astral for both the strict and permissive set of gene trees.
bash run_astral.sh

# Copy the exon alignments of the selected genes from the ortholog_identification directory.
bash get_exon_alignments_of_selected_genes.sh

# Identify indels in the selected exon alignments.
bash find_indels.sh

# Make a maximum-parsimony tree based on indels with paup.
bash run_paup_with_indels.sh

# Group gene alignments according to rate or site model using partitionfinder.
bash run_partitionfinder.sh

# Prepare input files for starbeast.
# This was done manually based on the partitionfinder output. The xml files are placed in ../data/xml.

# Prepare the starbeast analyses.
bash prepare_starbeast_analyses.sh

# Run all starbeast analyses.
bash run_starbeast.sh

# Combine the results of all starbeast analyses.
bash combine_starbeast_results.sh