# m_matschiner Tue Aug 14 18:05:12 CEST 2018

# Load libraries.
suppressMessages(library(genealogicalSorting))

# Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)
tree_file_name <- args[1]
assignment_table_file_name <- args[2]
group_string <- args[3]

# Read the tree.
tree <- read.tree(tree_file_name)

# Read the assignment file.
assignment <- readAssignmentFile(assignment_table_file_name, tree)

# Calculate and report the gsi value for this group.
cat(gsi(tree, group_string, assignment))