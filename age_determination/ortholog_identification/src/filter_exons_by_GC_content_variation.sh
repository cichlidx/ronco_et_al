# m_matschiner Sun Jul 22 15:15:26 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/alignments/orthologs/07
rm -f ../res/alignments/orthologs/07/*

# Remove exons that are outliers in gc-content variation.
ruby filter_exons_by_GC_content_variation.rb ../res/alignments/nuclear/06 ../res/alignments/nuclear/07 0.04