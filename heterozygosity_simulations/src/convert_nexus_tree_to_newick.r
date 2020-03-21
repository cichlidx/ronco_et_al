# m_matschiner Thu Sep 27 12:23:48 CEST 2018

# This script converts a phylogenetic tree in
# Nexus format to Newick format.

# Load the ape library.
library(ape)

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
innexus_tree_file_name <- args[1]
outnewick_tree_file_name <- args[2]

# Read the tree.
innexus_tree <- read.nexus(innexus_tree_file_name)

# Write the tree to the output file.
write.tree(innexus_tree, file=outnewick_tree_file_name)