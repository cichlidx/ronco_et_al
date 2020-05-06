# m_matschiner Thu Dec 13 14:26:15 CET 2018

# Load libraries.
library(ape)

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
intree_file_name <- args[1]
outtree_file_name <- args[2]
support_threshold <- args[3]

# Read the input tree file.
intree <- read.tree(intree_file_name)

# Collapse nodes with low support.
outtree <- di2multi(intree,tol=support_threshold)

# Write the output tree.
write.tree(outtree, outtree_file_name)