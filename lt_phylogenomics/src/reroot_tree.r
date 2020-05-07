# m_matschiner Wed Oct 17 13:24:03 CEST 2018

# Load libraries.
library(ape)

# Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)
intree_file_name <- args[1]
outtree_file_name <- args[2]
outgroups <- args[3:length(args)] # c("Gobeth", "Tilbre", "Hetbut") # args[3]

# Read the tree.
tree <- read.tree(intree_file_name)

# Remove all tips not in the keep list.
rerooted_tree <- root(tree, outgroup=outgroups, resolve.root=TRUE)

# Write the pruned tree to file.
write.tree(rerooted_tree,file=outtree_file_name)
