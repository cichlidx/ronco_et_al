# m_matschiner Thu Nov 15 11:19:46 CET 2018

# Load the coda library.
library(coda)

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
log_file_name <- args[1]

# Read the log file as a table.
t <- read.table(log_file_name, header=T)

# Get the chain length as the number of rows in the table.
chain_length = dim(t)[1]

# Convert the table into a mcmc object.
MCMCdata = mcmc(data=t, start=1, end=chain_length, thin=1)

# Make a subset of the mcmc object, removing the burnin and some parameter traces.
MCMCsub <- as.mcmc(MCMCdata[(chain_length/10):chain_length, c(2, 3, 4, 8, 9, 10)])

# Find the lowest effective sample size.
cat(min(effectiveSize(MCMCsub)), "\n")