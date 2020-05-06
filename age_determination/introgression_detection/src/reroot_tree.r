# m_matschiner Wed Dec 12 23:35:18 CET 2018

# Load libraries.
library(ape)

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
intree_file_name <- args[1]
outtree_file_name <- args[2]
outgroup_list <- args[3:length(args)]

# Read the input tree file.
intree <- read.tree(intree_file_name)

# Reroot the tree.
outtree <- root(intree, outgroup=outgroup_list)

# Write the output tree file.
write.tree(outtree, outtree_file_name)
