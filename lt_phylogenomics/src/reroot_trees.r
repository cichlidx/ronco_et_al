# m_matschiner Thu May 30 14:27:16 CEST 2019

# Load libraries.
library(ape)

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
in_trees_file_name <- args[1]
out_trees_file_name <- args[2]

# Read trees.
trees <- read.tree(in_trees_file_name)

# Root trees with gobeth.
rooted_trees <- root(trees, "Gobeth")

# Write the rooted trees to file.
write.tree(rooted_trees, out_trees_file_name)