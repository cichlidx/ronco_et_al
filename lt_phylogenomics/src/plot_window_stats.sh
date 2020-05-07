# m_matschiner Fri Oct 5 18:44:20 CEST 2018

# Load the r module .
module load R/3.4.4

# Make the output directory.
mkdir -p ../res/plots

# Run an r script for plotting.
Rscript plot_window_stats.r ../res/tables/windows/stats.txt ../res/plots