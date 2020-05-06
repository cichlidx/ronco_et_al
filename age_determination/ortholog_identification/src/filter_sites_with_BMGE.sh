# m_matschiner Sat Mar 18 17:28:45 CET 2017

# Load the ruby module
module load ruby/2.1.5

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/alignments/nuclear/05

# Filter sites for missing data and entropy with BMGE.
ruby filter_sites_with_BMGE.rb ../bin/BMGE.jar ../res/alignments/nuclear/04/ ../res/alignments/nuclear/05/ 0.2 0.5