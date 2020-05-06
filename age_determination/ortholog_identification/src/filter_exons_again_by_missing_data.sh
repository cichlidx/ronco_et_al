# m_matschiner Mon Nov 12 13:11:13 CET 2018

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/alignments/nuclear/06

# Filter exon alignments by their completeness.
ruby filter_exons_by_missing_data.rb ../res/alignments/nuclear/05 ../res/alignments/nuclear/06 10 150